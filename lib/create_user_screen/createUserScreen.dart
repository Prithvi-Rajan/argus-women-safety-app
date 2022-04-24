import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:womensafteyhackfair/Dashboard/Dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme.dart';
import 'package:path/path.dart' as path;

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({Key key}) : super(key: key);

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  XFile image;
  final _nameEditingController = TextEditingController();

  void _pickImage() async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  Future<String> uploadPic() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference =
        storage.ref("profile-images").child(path.basename(image.path));
    UploadTask uploadTask = reference.putFile(File(image.path));
    final taskSnapshot = await uploadTask;
    String location = await taskSnapshot.ref.getDownloadURL();
    return location;
  }

  void updateUser() async {
    String photoUrl = await uploadPic();
    if (photoUrl != null && _nameEditingController.text.isNotEmpty) {
      User _currentUser = FirebaseAuth.instance.currentUser;
      await _currentUser.updateDisplayName(_nameEditingController.text);
      await _currentUser.updatePhotoURL(photoUrl);
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      users.doc(_currentUser.uid).set({
        'name': _nameEditingController.text,
        'photoUrl': photoUrl,
        'uid': _currentUser.uid,
        'phoneNumber': _currentUser.phoneNumber,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Image.asset(
                  'assets/logo.png',
                  width: screenWidth * 0.3,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 28, color: Colors.black),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                const Text(
                  'Enter your details to proceed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? screenWidth * 0.2 : 16),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      // ignore: prefer_const_literals_to_create_immutables
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pickImage();
                        },
                        child: CircleAvatar(
                            foregroundImage: image == null
                                ? null
                                : FileImage(File(image.path)),
                            backgroundColor: themeColor.withAlpha(100),
                            radius: screenWidth * 0.2,
                            child: Icon(Icons.photo_camera_front_outlined,
                                size: 48)),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 55,
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Name',
                          ),
                          controller: _nameEditingController,
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(themeColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          updateUser();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Dashboard(),
                              ),
                              (route) => false);
                        },
                        child: Container(
                          width: screenWidth * 0.35,
                          child: const Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
