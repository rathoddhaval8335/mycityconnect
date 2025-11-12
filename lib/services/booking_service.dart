import 'package:firebase_database/firebase_database.dart';
import '../models/booking_model.dart';

class BookingService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> createBooking(BookingModel booking) async {
    try {
      // Generate a proper ID if not provided
      final bookingId = booking.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      booking.id = bookingId;

      // Store under user's bookings
      await _database
          .child('users')
          .child(booking.userId)
          .child('bookings')
          .child(bookingId)
          .set(booking.toJson());

      // Also store in general bookings collection for admin access
      await _database
          .child('bookings')
          .child(bookingId)
          .set(booking.toJson());

      print('Booking created successfully with ID: $bookingId');
    } catch (e) {
      print('Error creating booking: $e');
      throw e;
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      DataSnapshot snapshot = await _database
          .child('users')
          .child(userId)
          .child('bookings')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map;
        List<BookingModel> bookings = [];

        data.forEach((key, value) {
          try {
            bookings.add(BookingModel.fromJson(Map<String, dynamic>.from(value)));
          } catch (e) {
            print('Error parsing booking: $e');
          }
        });

        // Sort by creation date (newest first)
        bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return bookings;
      }
      return [];
    } catch (e) {
      print('Error getting user bookings: $e');
      return [];
    }
  }

  Future<List<BookingModel>> getAllBookings() async {
    try {
      DataSnapshot snapshot = await _database.child('bookings').get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map;
        List<BookingModel> bookings = [];

        data.forEach((key, value) {
          try {
            bookings.add(BookingModel.fromJson(Map<String, dynamic>.from(value)));
          } catch (e) {
            print('Error parsing booking: $e');
          }
        });

        // Sort by creation date (newest first)
        bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return bookings;
      }
      return [];
    } catch (e) {
      print('Error getting all bookings: $e');
      return [];
    }
  }

  Future<void> updateBookingStatus(String bookingId, String userId, String status) async {
    try {
      // Update in user's bookings
      await _database
          .child('users')
          .child(userId)
          .child('bookings')
          .child(bookingId)
          .update({
        'status': status,
      });

      // Update in general bookings collection
      await _database
          .child('bookings')
          .child(bookingId)
          .update({
        'status': status,
      });
    } catch (e) {
      print('Error updating booking status: $e');
      throw e;
    }
  }

  Future<void> deleteBooking(String bookingId, String userId) async {
    try {
      // Delete from user's bookings
      await _database
          .child('users')
          .child(userId)
          .child('bookings')
          .child(bookingId)
          .remove();

      // Delete from general bookings collection
      await _database
          .child('bookings')
          .child(bookingId)
          .remove();

      print('Booking deleted successfully with ID: $bookingId');
    } catch (e) {
      print('Error deleting booking: $e');
      throw e;
    }
  }

  Future<bool> canDeleteBooking(BookingModel booking) async {
    // Only allow deletion for pending bookings
    return booking.status == 'pending';
  }

  Future<void> cancelBooking(String bookingId, String userId) async {
    await updateBookingStatus(bookingId, userId, 'cancelled');
  }

}