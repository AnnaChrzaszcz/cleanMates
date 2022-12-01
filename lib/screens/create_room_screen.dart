import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateRoomScreen extends StatefulWidget {
  static const routeName = '/addNewRoom';
  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _roomName = '';

  Future<void> _createNewRoom() async {
    final formValid = _form.currentState.validate();

    if (formValid) {
      _form.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        final user = await FirebaseAuth.instance.currentUser;
        final roomieData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final newRoomRef =
            await FirebaseFirestore.instance.collection('rooms').doc();
        await newRoomRef.set({'roomName': _roomName, 'creatorId': user.uid});
        await newRoomRef.collection('roomies').doc(user.uid).set({
          'roomie': roomieData.reference,
          'points': 0,
        });

        final roomRoomieRef = await newRoomRef.get();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .update({'roomRef': roomRoomieRef.reference});
      } catch (err) {
        print(err);
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create new room'),
        actions: [
          IconButton(onPressed: _createNewRoom, icon: Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Room Name'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) {
                        _roomName = value;
                      },
                      validator: (value) {
                        if (value.isEmpty)
                          return 'you have to enter a room name';
                        else
                          return null;
                      },
                    ),
                    Text('tu bedzie lista mozliwych osob do dodania?'),
                  ],
                ),
              ),
      ),
    );
  }
}
