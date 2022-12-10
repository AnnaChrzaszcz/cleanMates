import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../models/exceptions/logistic_expection.dart';
import '../models/gift.dart';

import '../models/activity.dart';
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

  Future<void> getYourRoom(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

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
        imageUrl: imageUrl,
        activities: [],
        gifts: [],
      );

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

    getYourRoom(user.uid);
    //notifyListeners();
  }

  Future<void> leaveRoom(Room room) async {
    final roomieData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final newRoomRef =
        await FirebaseFirestore.instance.collection('rooms').doc(room.id);

    var activitiesToDeleteCollection = await newRoomRef
        .collection('roomies')
        .doc(user.uid)
        .collection('activities')
        .get();

    for (var doc in activitiesToDeleteCollection.docs) {
      await doc.reference.delete();
    }

    await newRoomRef.collection('roomies').doc(user.uid).delete();

    final roomRoomieRef = await newRoomRef.get();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'roomRef': FieldValue.delete()});
    userRoom = null;
    notifyListeners();
  }

  Future<void> addRoom(Room room) async {
    final roomieData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final newRoomRef =
        await FirebaseFirestore.instance.collection('rooms').doc();

    await newRoomRef.set({
      'roomName': room.roomName,
      'creatorId': user.uid,
    });
    await newRoomRef.collection('roomies').doc(user.uid).set({
      'roomie': roomieData.reference,
      'points': 0,
    });

    final roomRoomieRef = await newRoomRef.get();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({'roomRef': roomRoomieRef.reference});

    final roomiesData = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(newRoomRef.id)
        .collection('roomies')
        .get();

    final newRoom = Room(
        id: newRoomRef.id,
        roomName: room.roomName,
        creatorId: user.uid,
        roomies: await _createRoomies(roomiesData));

    _rooms.add(newRoom);
    userRoom = newRoom;
    notifyListeners();
  }

  Future<void> addActivitiesToRoomie(List<Activity> newActivities,
      String userId, String roomId, int pointsEarned) async {
    final activityData = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('roomies')
        .doc(userId)
        .collection('activities');

    FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('roomies')
        .doc(userId)
        .get()
        .then((snapshot) {
      Map<String, dynamic> roomieData = snapshot.data();
      var points = roomieData['points'];
      int pointsSum = points + pointsEarned;

      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('roomies')
          .doc(userId)
          .update({'points': pointsSum});
    });

    List<Map<String, dynamic>> values = [];
    Roomie roomie =
        userRoom.roomies.firstWhere((roomie) => roomie.id == userId);

    var roomieIndex =
        userRoom.roomies.indexWhere((roomie) => roomie.id == userId);
    List<Activity> activities = roomie.activities ?? [];

    try {
      for (var activity in newActivities) {
        var value = {
          'activityId': activity.id,
          'dateTime': DateTime.now().toIso8601String(),
        };

        DocumentReference activitySnapshot = await activityData.add(value);

        Activity newActivity = Activity(
            id: activitySnapshot.id,
            activityName: activity.activityName,
            points: activity.points,
            roomId: roomId);

        activities.add(newActivity);
      }

      Roomie updatedRoomie = Roomie(
          id: roomie.id,
          userName: roomie.userName,
          points: roomie.points + pointsEarned,
          imageUrl: roomie.imageUrl,
          activities: activities);

      myRoom.roomies[roomieIndex] = updatedRoomie;
      myRoom.roomies.forEach(
        (element) => print(element.points),
      );
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }

  Future<void> addGiftsToRoomie(List<Gift> newGifts, String userId,
      String roomId, int pointsSpent) async {
    final giftsData = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('roomies')
        .doc(userId)
        .collection('gifts');

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('roomies')
        .doc(userId)
        .get();

    Map<String, dynamic> roomieData = snapshot.data();
    var points = roomieData['points'];
    int pointsActual = points - pointsSpent;
    print('w room provider buy gifts');
    print(points);
    if (pointsActual < 0) {
      notifyListeners();
      throw LogisticExpection('Not enough points. You have $points points');
    } else {
      FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .collection('roomies')
          .doc(userId)
          .update({'points': pointsActual});

      List<Map<String, dynamic>> values = [];
      Roomie roomie =
          userRoom.roomies.firstWhere((roomie) => roomie.id == userId);
      List<Gift> gifts = roomie.gifts ?? [];

      try {
        for (var gift in newGifts) {
          var value = {
            'giftId': gift.id,
            'dateTime': DateTime.now().toIso8601String(),
            'realized': false,
          };

          DocumentReference giftSnapshot = await giftsData.add(value);

          Gift newGift = Gift(
              id: giftSnapshot.id,
              giftName: gift.giftName,
              points: gift.points,
              roomId: roomId,
              isRealized: false);

          gifts.add(newGift);
        }

        var roomieIndex =
            userRoom.roomies.indexWhere((roomie) => roomie.id == userId);

        Roomie updatedRoomie = Roomie(
            id: roomie.id,
            userName: roomie.userName,
            points: roomie.points - pointsSpent,
            imageUrl: roomie.imageUrl,
            gifts: gifts,
            activities: roomie.activities);

        myRoom.roomies[roomieIndex] = updatedRoomie;
        myRoom.roomies.forEach(
          (element) => print(element.points),
        );
        notifyListeners();
      } catch (err) {
        rethrow;
      }
    }
  }

  Future<List<Gift>> getUserGifts(
    String userId,
  ) async {
    List<Gift> gifts = [];
    QuerySnapshot<Map<String, dynamic>> giftsData = await FirebaseFirestore
        .instance
        .collection('rooms')
        .doc(userRoom.id)
        .collection('roomies')
        .doc(userId)
        .collection('gifts')
        .get();

    giftsData.docs.forEach((gift) {
      print(gift['giftId']);
    });

    return gifts;
  }
}
