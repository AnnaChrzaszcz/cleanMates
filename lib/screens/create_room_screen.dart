import 'package:clean_mates_app/providers/rooms_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';
import 'package:provider/provider.dart';
import '../providers/activities_provider.dart';

class CreateRoomScreen extends StatefulWidget {
  static const routeName = '/addNewRoom';
  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _initValues = {'roomName': '', 'creatorId': ''};
  var _isInit = true;

  var _editedRoom = Room(id: null, creatorId: '', roomName: '', roomies: []);

  void didChangeDependencies() {
    if (_isInit) {
      final id = ModalRoute.of(context).settings.arguments as String;
    }
    _isInit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  Future<void> _createNewRoom() async {
    final formValid = _form.currentState.validate();

    if (formValid) {
      _form.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<RoomsProvider>(context, listen: false)
            .addNewRoom(_editedRoom);
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
        // actions: [
        //   IconButton(onPressed: _createNewRoom, icon: Icon(Icons.save))
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: Form(
                      key: _form,
                      child: ListView(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Room Name'),
                            textInputAction: TextInputAction.next,
                            onSaved: (value) {
                              _editedRoom = Room(
                                  id: _editedRoom.id,
                                  roomName: value,
                                  creatorId: _editedRoom.creatorId,
                                  roomies: _editedRoom.roomies);
                            },
                            validator: (value) {
                              if (value.isEmpty)
                                return 'you have to enter a room name';
                              else
                                return null;
                            },
                          ),
                          // Text('tu bedzie lista mozliwych osob do dodania?'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 30),
                    child: ElevatedButton(
                      onPressed: _createNewRoom,
                      child: Text('Save'),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
