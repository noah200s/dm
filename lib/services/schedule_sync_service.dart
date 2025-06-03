import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Convert detailed schedule to booking-compatible format
  static Map<String, dynamic> convertToBookingFormat(Map<String, dynamic> detailedSchedule) {
    Map<String, dynamic> bookingSchedule = {};
    
    detailedSchedule.forEach((dateKey, dayData) {
      if (dayData['isWorking'] == true) {
        final timeSlots = dayData['timeSlots'] as List? ?? [];
        
        if (timeSlots.isNotEmpty) {
          // Convert time slots to booking format
          List<Map<String, dynamic>> availableSlots = [];
          
          for (var slot in timeSlots) {
            final startTime = slot['startTime'] as String;
            final endTime = slot['endTime'] as String;
            
            // Generate 30-minute slots
            final slots = _generateTimeSlots(startTime, endTime);
            availableSlots.addAll(slots);
          }
          
          bookingSchedule[dateKey] = {
            'isAvailable': true,
            'slots': availableSlots,
            'lastUpdated': FieldValue.serverTimestamp(),
          };
        }
      }
    });
    
    return bookingSchedule;
  }

  /// Generate 30-minute time slots between start and end time
  static List<Map<String, dynamic>> _generateTimeSlots(String startTime, String endTime) {
    List<Map<String, dynamic>> slots = [];
    
    try {
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);
      
      DateTime current = start;
      while (current.isBefore(end)) {
        final next = current.add(const Duration(minutes: 30));
        if (next.isAfter(end)) break;
        
        slots.add({
          'startTime': _formatTime(current),
          'endTime': _formatTime(next),
          'isBooked': false,
          'patientId': null,
          'patientName': null,
        });
        
        current = next;
      }
    } catch (e) {
      print('Error generating time slots: $e');
    }
    
    return slots;
  }

  /// Parse time string to DateTime
  static DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Format DateTime to time string
  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Sync doctor schedule to booking system
  static Future<void> syncScheduleToBookingSystem(String doctorId, Map<String, dynamic> detailedSchedule) async {
    try {
      print('🔄 Starting sync for doctor: $doctorId');
      print('📅 Schedule data: $detailedSchedule');

      // Get current booking schedule to preserve existing bookings
      final doc = await _firestore.collection('doctors').doc(doctorId).get();
      Map<String, dynamic> currentBookingSchedule = {};

      if (doc.exists) {
        currentBookingSchedule = Map<String, dynamic>.from(
          doc.data()?['bookingSchedule'] ?? {}
        );
      }

      // Convert new schedule to booking format
      final newBookingSchedule = convertToBookingFormat(detailedSchedule);
      print('🔄 Converted to booking format: $newBookingSchedule');

      // Merge with existing schedule, preserving bookings
      newBookingSchedule.forEach((dateKey, newDaySchedule) {
        final existingDaySchedule = currentBookingSchedule[dateKey] as Map<String, dynamic>?;

        // Check if the day is still working
        if (newDaySchedule['isAvailable'] == true) {
          if (existingDaySchedule != null) {
            // Preserve existing bookings
            final existingSlots = existingDaySchedule['slots'] as List? ?? [];
            final newSlots = newDaySchedule['slots'] as List? ?? [];

            // Create a map of existing booked slots
            Map<String, Map<String, dynamic>> bookedSlots = {};
            for (var slot in existingSlots) {
              if (slot['isBooked'] == true) {
                bookedSlots[slot['startTime']] = Map<String, dynamic>.from(slot);
              }
            }

            // Update new slots with existing bookings
            for (int i = 0; i < newSlots.length; i++) {
              final startTime = newSlots[i]['startTime'];
              if (bookedSlots.containsKey(startTime)) {
                newSlots[i] = bookedSlots[startTime]!;
              }
            }
          }

          currentBookingSchedule[dateKey] = newDaySchedule;
        } else {
          // Day is not working anymore - remove it completely
          print('🗑️ Removing day $dateKey from booking schedule (not working)');
          currentBookingSchedule.remove(dateKey);
        }
      });

      // Update doctor's booking schedule
      await _firestore.collection('doctors').doc(doctorId).update({
        'bookingSchedule': currentBookingSchedule,
        'lastScheduleSync': FieldValue.serverTimestamp(),
      });

      print('✅ Schedule synced successfully for doctor: $doctorId');
    } catch (e) {
      print('❌ Error syncing schedule: $e');
      rethrow;
    }
  }

  /// Get available slots for a specific date
  static Future<List<Map<String, dynamic>>> getAvailableSlotsForDate(String doctorId, String dateKey) async {
    try {
      final doc = await _firestore.collection('doctors').doc(doctorId).get();
      
      if (doc.exists) {
        final bookingSchedule = doc.data()?['bookingSchedule'] as Map<String, dynamic>? ?? {};
        final daySchedule = bookingSchedule[dateKey] as Map<String, dynamic>? ?? {};
        
        if (daySchedule['isAvailable'] == true) {
          final slots = daySchedule['slots'] as List? ?? [];
          return slots.map((slot) => Map<String, dynamic>.from(slot)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting available slots: $e');
      return [];
    }
  }

  /// Book a specific time slot
  static Future<bool> bookTimeSlot(String doctorId, String dateKey, String slotStartTime, Map<String, dynamic> patientInfo) async {
    try {
      final docRef = _firestore.collection('doctors').doc(doctorId);
      
      return await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        
        if (!doc.exists) return false;
        
        final data = doc.data()!;
        final bookingSchedule = Map<String, dynamic>.from(data['bookingSchedule'] ?? {});
        final daySchedule = Map<String, dynamic>.from(bookingSchedule[dateKey] ?? {});
        final slots = List<Map<String, dynamic>>.from(daySchedule['slots'] ?? []);
        
        // Find and book the slot
        bool slotFound = false;
        for (int i = 0; i < slots.length; i++) {
          if (slots[i]['startTime'] == slotStartTime && slots[i]['isBooked'] == false) {
            slots[i] = {
              ...slots[i],
              'isBooked': true,
              'patientId': patientInfo['id'],
              'patientName': patientInfo['name'],
              'patientPhone': patientInfo['phone'],
              'bookedAt': FieldValue.serverTimestamp(),
            };
            slotFound = true;
            break;
          }
        }
        
        if (!slotFound) return false;
        
        // Update the schedule
        daySchedule['slots'] = slots;
        bookingSchedule[dateKey] = daySchedule;
        
        transaction.update(docRef, {
          'bookingSchedule': bookingSchedule,
        });
        
        return true;
      });
    } catch (e) {
      print('Error booking time slot: $e');
      return false;
    }
  }

  /// Cancel a booking
  static Future<bool> cancelBooking(String doctorId, String dateKey, String slotStartTime) async {
    try {
      final docRef = _firestore.collection('doctors').doc(doctorId);
      
      return await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        
        if (!doc.exists) return false;
        
        final data = doc.data()!;
        final bookingSchedule = Map<String, dynamic>.from(data['bookingSchedule'] ?? {});
        final daySchedule = Map<String, dynamic>.from(bookingSchedule[dateKey] ?? {});
        final slots = List<Map<String, dynamic>>.from(daySchedule['slots'] ?? []);
        
        // Find and cancel the slot
        bool slotFound = false;
        for (int i = 0; i < slots.length; i++) {
          if (slots[i]['startTime'] == slotStartTime && slots[i]['isBooked'] == true) {
            slots[i] = {
              'startTime': slots[i]['startTime'],
              'endTime': slots[i]['endTime'],
              'isBooked': false,
              'patientId': null,
              'patientName': null,
              'patientPhone': null,
              'cancelledAt': FieldValue.serverTimestamp(),
            };
            slotFound = true;
            break;
          }
        }
        
        if (!slotFound) return false;
        
        // Update the schedule
        daySchedule['slots'] = slots;
        bookingSchedule[dateKey] = daySchedule;
        
        transaction.update(docRef, {
          'bookingSchedule': bookingSchedule,
        });
        
        return true;
      });
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  /// Get doctor's appointments for a specific date
  static Future<List<Map<String, dynamic>>> getDoctorAppointments(String doctorId, String dateKey) async {
    try {
      final doc = await _firestore.collection('doctors').doc(doctorId).get();
      
      if (doc.exists) {
        final bookingSchedule = doc.data()?['bookingSchedule'] as Map<String, dynamic>? ?? {};
        final daySchedule = bookingSchedule[dateKey] as Map<String, dynamic>? ?? {};
        final slots = daySchedule['slots'] as List? ?? [];
        
        // Return only booked slots
        return slots
            .where((slot) => slot['isBooked'] == true)
            .map((slot) => Map<String, dynamic>.from(slot))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  /// Stream of doctor's schedule changes
  static Stream<Map<String, dynamic>> getDoctorScheduleStream(String doctorId) {
    return _firestore
        .collection('doctors')
        .doc(doctorId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return doc.data()?['detailedSchedule'] as Map<String, dynamic>? ?? {};
      }
      return <String, dynamic>{};
    });
  }

  /// Stream of doctor's booking schedule changes
  static Stream<Map<String, dynamic>> getDoctorBookingScheduleStream(String doctorId) {
    return _firestore
        .collection('doctors')
        .doc(doctorId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return doc.data()?['bookingSchedule'] as Map<String, dynamic>? ?? {};
      }
      return <String, dynamic>{};
    });
  }
}
