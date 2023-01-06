import 'dart:io';
import 'package:clean_mates_app/screens/user_dashboard_screen.dart';
import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UserProfile extends StatefulWidget {
  static const routeName = '/profile';

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  File pickedImageFile;
  User user;
  bool isLoading = false;
  bool isLoading1 = false;

  void _pickImage() async {
    setState(() {
      isLoading1 = true;
    });
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 1,
    ); //maxWidth: 150
    if (pickedImage != null) {
      setState(() {
        pickedImageFile = File(pickedImage.path);
        isLoading1 = false;
      });
    }
    setState(() {
      isLoading1 = false;
    });
  }

  Future<void> _saveUpdate(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    await FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child('${user.uid}.jpg')
        .putFile(pickedImageFile);

    final _url = await FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child('${user.uid}.jpg')
        .getDownloadURL();

    await user.updatePhotoURL(_url);
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushReplacementNamed(UserDashboardScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    var routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    if (routeArgs != null) {
      user = routeArgs['user'];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your profile'),
        actions: [
          IconButton(
              onPressed: () => _saveUpdate(context),
              icon: const Icon(Icons.save))
        ],
      ),
      drawer: AppDrawer(),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: user.uid,
              child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(247, 219, 79, 1),
                  radius: 90,
                  child: !isLoading1
                      ? CircleAvatar(
                          radius: 85,
                          backgroundImage: pickedImageFile != null
                              ? FileImage(pickedImageFile)
                              : NetworkImage(user.photoURL))
                      : CircleAvatar(
                          radius: 85,
                          child: LoadingAnimationWidget.hexagonDots(
                              color: Colors.white, size: 20),
                        )),
            ),
            SizedBox(height: 10),
            if (!isLoading)
              TextButton(
                child: Text('Update image', style: TextStyle(fontSize: 20)),
                onPressed: _pickImage,
              ),
            if (isLoading)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 50),
                child: LinearProgressIndicator(),
              )
          ],
        ),
      ),
    );
  }
}
