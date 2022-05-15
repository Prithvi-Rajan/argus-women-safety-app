import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utility_service.dart';

void updateContacts(List<String> contacts) async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  User _currentUser = FirebaseAuth.instance.currentUser;
  await users.doc(_currentUser.uid).update({
    'emergencyContacts': extractNumbers(contacts),
  });
}

void setAlertStatus(bool status) async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  User _currentUser = FirebaseAuth.instance.currentUser;
  await users.doc(_currentUser.uid).update({'alert': status});
}
