import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class DatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> saveUser(UserModel user) async {
    await _database.child('users').child(user.id!).set(user.toJson());
  }

  Future<UserModel?> getUser(String userId) async {
    DataSnapshot snapshot = await _database.child('users').child(userId).get();
    if (snapshot.value != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }
}