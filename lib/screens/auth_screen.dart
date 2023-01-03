import 'dart:io'; // at beginning of file
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import '../widgets/auth/auth_form.dart';
import 'package:rive/rive.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(String email, String username, String password,
      File image, bool isLogin, BuildContext ctx) async {
    UserCredential userCredential;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        User user = userCredential.user;
        await user.updateDisplayName(username);

        print(image.path);

        await FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${user.uid}.jpg')
            .putFile(image);

        final url = await FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${user.uid}.jpg')
            .getDownloadURL();

        await user.updatePhotoURL(url);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': url,
          'points': 0
        });
      }
    } on PlatformException catch (err) {
      var message = 'An error occured, please check your credentials';
      if (err.message != null) {
        message = err.message;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(err.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        height: MediaQuery.of(context).size.height,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.height / 6,
                    height: MediaQuery.of(context).size.height / 6,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  AuthForm(_submitAuthForm, _isLoading)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
