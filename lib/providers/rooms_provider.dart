import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/roomie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomsProvider extends ChangeNotifier {
  List<Room> _rooms;
  Room userRoom;
  final user = FirebaseAuth.instance.currentUser;

  RoomsProvider(this._rooms, this.userRoom);

  List<Room> get rooms {
    return [..._rooms];
  }

  Room get myRoom {
    return userRoom;
  }

  Future<void> getYourRoom(user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await userRef.get();
    final room = doc.data() as Map<String, dynamic>;
    if (room.containsKey('roomRef')) {
      DocumentSnapshot roomSnapshot = await room['roomRef'].get();
      final roomData = roomSnapshot.data() as Map<String, dynamic>;

      final value = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomSnapshot.id)
          .collection('roomies')
          .get();

      final List<Roomie> roomies = await _createRoomies(value);

      Room roomItem = Room(
          id: roomSnapshot.reference.id,
          roomName: roomData['roomName'],
          creatorId: roomData['creatorId'],
          roomies: roomies);
      userRoom = roomItem;
      notifyListeners();
    }
  }

  Future<List<Roomie>> _createRoomies(
      QuerySnapshot<Map<String, dynamic>> value) async {
    final List<Roomie> roomies = [];

    for (var element in value.docs) {
      DocumentSnapshot roomieSnapshot =
          await element['roomie'].get(); //tu bylo roomies
      final username =
          (roomieSnapshot.data() as Map<String, dynamic>)['username'];
      final imageUrl =
          (roomieSnapshot.data() as Map<String, dynamic>)['image_url'];
      Roomie newRoomie = Roomie(
          id: roomieSnapshot.reference.id,
          points: element['points'],
          userName: username,
          imageUrl: imageUrl);

      roomies.add(newRoomie);
    }
    return roomies;
  }

  Future<void> joinToRoom(Room room) async {
    final roomieData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final newRoomRef =
        await FirebaseFirestore.instance.collection('rooms').doc(room.id);

    // await newRoomRef.set({'roomName': _roomName, 'creatorId': user.uid});
    await newRoomRef.collection('roomies').doc(user.uid).set({
      'roomie': roomieData.reference,
      'points': 0,
    });

    final roomRoomieRef = await newRoomRef.get();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'roomRef': roomRoomieRef.reference});

    notifyListeners();
  }

  Future<void> leaveRoom(Room room) async {
    final roomieData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final newRoomRef =
        await FirebaseFirestore.instance.collection('rooms').doc(room.id);
    await newRoomRef.collection('roomies').doc(user.uid).delete();

    final roomRoomieRef = await newRoomRef.get();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'roomRef': FieldValue.delete()});
    userRoom = null;
    notifyListeners();
  }
}
