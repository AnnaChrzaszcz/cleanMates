import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/roomie.dart';

class RoomRepository with ChangeNotifier {
  final user = FirebaseAuth.instance.currentUser;

  Future<Room> getYourRoom(user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await userRef.get();
    final room = doc.data() as Map<String, dynamic>;
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
    notifyListeners();
    return roomItem;
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

  Future<List<Room>> getAllRooms(user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    List<Room> rooms = [];

    final doc = await userRef.get();

    QuerySnapshot value =
        await FirebaseFirestore.instance.collection('rooms').get();

    rooms = await _createRooms(value);
    return rooms;
  }

  Future<List<Room>> _createRooms(QuerySnapshot<Object> value) async {
    List<Room> rooms = [];
    for (var element in value.docs) {
      final roomData = element.data() as Map<String, dynamic>;
      final roomiesCollection =
          await element.reference.collection('roomies').get(); //tu bylo roomies
      List<Roomie> roomies = await _createRoomies(roomiesCollection);

      Room room = Room(
          id: element.id,
          roomName: roomData['roomName'],
          creatorId: roomData['creatorId'],
          roomies: roomies);
      rooms.add(room);
    }
    return rooms;
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
  }
}
