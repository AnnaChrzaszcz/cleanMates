import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/auth/auth_form.dart';
import 'package:rive/rive.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  User user;
  var url;

  Future<void> _submitAuthForm(String email, String username, String password,
      File image, bool isLogin, BuildContext ctx) async {
    UserCredential userCredential;
    try {
      setState(() {
        _isLoading = true;
      });

      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        user = userCredential.user;
        await user.updateDisplayName(user.displayName);
        await user.updatePhotoURL(user.photoURL);
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        user = userCredential.user;

        if (image == null) {
          url = await FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child('149071.png')
              .getDownloadURL();
        } else {
          await FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child('${user.uid}.jpg')
              .putFile(image);

          url = await FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child('${user.uid}.jpg')
              .getDownloadURL();
        }
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': url,
          'points': 0
        });

        await user.updateDisplayName(username);
        await user.updatePhotoURL(url);
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
        margin: const EdgeInsets.symmetric(vertical: 15),
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
