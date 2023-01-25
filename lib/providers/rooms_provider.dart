import 'package:clean_mates_app/models/userActivity.dart';
import 'package:clean_mates_app/models/userGift.dart';
import '../models/exceptions/logistic_expection.dart';
import '../models/gift.dart';
import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/roomie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomsProvider extends ChangeNotifier {
  List<Room> _rooms;
  Room userRoom;
  User user = FirebaseAuth.instance.currentUser;

  RoomsProvider(this._rooms, this.userRoom);

  List<Room> get rooms {
    return [..._rooms];
  }

  Room get myRoom {
    return userRoom;
  }

  Future<List<Room>> getAvailableRooms() async {
    List<Room> availableRooms = [];
    QuerySnapshot<Map<String, dynamic>> roomsQuerySnapshot =
        await FirebaseFirestore.instance.collection('rooms').get();

    roomsQuerySnapshot.docs.forEach((room) async {
      CollectionReference<Map<String, dynamic>> a =
          room.reference.collection('roomies');
      QuerySnapshot<Map<String, dynamic>> b = await a.get();
      if (b.docs.length == 1) {
        availableRooms.add(Room(
            id: room.id,
            roomName: room['roomName'],
            creatorId: await getUsernameFromId(room['creatorId']),
            roomies: [],
            roomiesActivites: [],
            roomiesGift: []));
      }
    });
    return availableRooms;
  }

  Future<Room> getUserRoom(String userId) async {
    user = FirebaseAuth.instance.currentUser;
    //DO POPRAWY MORDO
    print('jestew w rooms provider getUserRoom');
    List<Roomie> roomies = [];
    List<UserActivity> roomiesActivities = [];
    List<UserGift> roomiesGifts = [];

    DocumentSnapshot<Map<String, dynamic>> roomieSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final userData = roomieSnapshot.data();
    if (userData.containsKey('roomId')) {
      //W USER POPRAWIC NA PRZECHOWYWANIE ROOM ID A NIE REFERENCJI
      var roomId = userData['roomId'];
      DocumentSnapshot<Map<String, dynamic>> roomSnapshot =
          await FirebaseFirestore.instance
              .collection('rooms')
              .doc(roomId)
              .get();
      final roomData = roomSnapshot.data();

      await roomSnapshot.reference.collection('roomies').get().then((value) {
        value.docs.forEach((element) async {
          var roomieData = element.data();
          var roomieId = roomieData['roomieId'];
          roomies.add(await _getRoomieFromId(roomieId));
        });
      });

      await roomSnapshot.reference
          .collection('roomiesActivities')
          .get()
          .then((value) {
        value.docs.forEach((element) async {
          var roomieActivityData = element.data();
          roomiesActivities.add(
            UserActivity(
                id: element.id,
                activityName: roomieActivityData['activityName'],
                points: roomieActivityData['points'],
                roomieId: roomieActivityData['roomieId'],
                creationDate:
                    DateTime.parse(roomieActivityData['creationDate'])),
          );
        });
      });

      await roomSnapshot.reference
          .collection('roomiesGifts')
          .get()
          .then((value) {
        value.docs.forEach((element) async {
          var roomieGiftData = element.data();
          roomiesGifts.add(
            UserGift(
                id: element.id,
                giftName: roomieGiftData['giftName'],
                points: roomieGiftData['points'],
                roomieId: roomieGiftData['roomieId'],
                isRealized: roomieGiftData['isRealized'],
                boughtDate: DateTime.parse(roomieGiftData['boughtDate']),
                realizedDate: roomieGiftData['isRealized']
                    ? DateTime.parse(roomieGiftData['realizedDate'])
                    : null),
          );
        });
      });

      userRoom = Room(
          id: roomSnapshot.id,
          roomName: roomData['roomName'],
          creatorId: roomData['creatorId'],
          roomies: roomies,
          roomiesActivites: roomiesActivities,
          roomiesGift: roomiesGifts);

      notifyListeners();
      return userRoom;
    }
  }

  Future<Roomie> _getRoomieFromId(String userId) async {
    //POPRAWIONE
    DocumentSnapshot<Map<String, dynamic>> roomieSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userData = roomieSnapshot.data();

    return Roomie(
        id: userId,
        userName: userData['username'],
        points: userData['points'],
        imageUrl: userData['image_url']);
  }

  Future<void> joinToRoom(String roomId) async {
    if (user == null) {
      user = FirebaseAuth.instance.currentUser;
    }
    //POPRAWIONE
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'roomId': roomId});

    DocumentReference<Map<String, dynamic>> newRoomRef =
        FirebaseFirestore.instance.collection('rooms').doc(roomId);

    await newRoomRef
        .collection('roomies')
        .doc(user.uid)
        .set({'roomieId': user.uid});

    userRoom = await getUserRoom(user.uid); // moze jakos inaczej?
  }

  Future<void> leaveRoom(String roomId) async {
    //POPRAWIONE
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'roomId': FieldValue.delete(), 'points': 0});

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('roomies')
        .doc(user.uid)
        .delete()
        .then(
          (doc) => print("Document deleted"),
          onError: (e) => print("Error updating document $e"),
        );
    await _deleteRoomieActivities(roomId, user.uid);
    await _deleteRoomieGifts(roomId, user.uid);

    userRoom = null;
    notifyListeners();
  }

  Future<void> _deleteRoomieActivities(String roomId, String userId) async {
    //POPRAWIONE
    Query<Map<String, dynamic>> activities_query = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('roomiesActivities')
        .where('roomieId', isEqualTo: userId);

    activities_query.get().then((activitiesSnapshot) {
      activitiesSnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });
  }

  Future<void> _deleteRoomieGifts(String roomId, String userId) async {
    //POPRAWIONE
    Query<Map<String, dynamic>> gifts_query = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('roomiesGifts')
        .where('roomieId', isEqualTo: userId);

    gifts_query.get().then((giftsSnapshot) {
      for (var doc in giftsSnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> addNewRoom(Room room) async {
    //POPRAWIONE
    final newRoomRef =
        await FirebaseFirestore.instance.collection('rooms').doc();

    await newRoomRef.set({
      'roomName': room.roomName,
      'creatorId': user.uid,
    });
    await newRoomRef.collection('roomies').doc(user.uid).set({
      'roomieId': user.uid,
    });

    final roomRoomieRef = await newRoomRef.get();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'roomId': newRoomRef.id});

    final newRoom = Room(
        id: newRoomRef.id,
        roomName: room.roomName,
        creatorId: user.uid,
        roomies: [await _getRoomieFromId(user.uid)],
        roomiesActivites: [],
        roomiesGift: []);

    //_rooms.add(newRoom);
    userRoom = newRoom;
    print('nowy pokoj utowrzony');
    print(userRoom.roomName);
    notifyListeners();
  }

  Future<void> addActivitiesToRoomie(
      //moze przerobic ze list<activity> jednak?
      //POPRAWIONE
      List<UserActivity> newActivities,
      String userId,
      int pointsEarned) async {
    final activityData = FirebaseFirestore.instance
        .collection('rooms')
        .doc(userRoom.id)
        .collection('roomiesActivities');

    for (var userActivity in newActivities) {
      await activityData.add({
        'activityName': userActivity.activityName,
        'points': userActivity.points,
        'roomieId': userId,
        'creationDate': DateTime.now().toIso8601String()
      }).then((documentSnapshot) {
        userRoom.roomiesActivites.add(UserActivity(
            id: documentSnapshot.id,
            activityName: userActivity.activityName,
            points: userActivity.points,
            roomieId: userId,
            creationDate: userActivity.creationDate));
      });
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((snapshot) {
      Map<String, dynamic> roomieData = snapshot.data();
      var points = roomieData['points'];

      int pointsSum = points + pointsEarned;

      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'points': pointsSum}).then((_) {
        var roomieIndex =
            myRoom.roomies.indexWhere((roomie) => roomie.id == userId);
        Roomie oldRoomie = myRoom.roomies[roomieIndex];
        Roomie updatedRoomie = Roomie(
            id: oldRoomie.id,
            userName: oldRoomie.userName,
            points: pointsSum,
            imageUrl: oldRoomie.imageUrl);
        myRoom.roomies[roomieIndex] = updatedRoomie;
        //getUserRoom(userId);
        //notifyListeners();
      }); // wrzucic to w try catch?
    });
    // notifyListeners(); // czy to poczeka na ten update?
  }

  Future<void> addGiftsToRoomie(List<Gift> newGifts, String userId,
      String roomId, int pointsSpent) async {
    final giftData = FirebaseFirestore.instance
        .collection('rooms')
        .doc(userRoom.id)
        .collection('roomiesGifts');

    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    Map<String, dynamic> roomieData = userSnapshot.data();

    var points = roomieData['points'];
    int pointsActual = points - pointsSpent;

    if (pointsActual < 0) {
      notifyListeners();
      throw LogisticExpection('Not enough points. You have $points points');
    } else {
      for (var userGift in newGifts) {
        //przy kupieniu prezentu po prostu nie dodaje pola realizeddate
        await giftData.add({
          'giftName': userGift.giftName,
          'points': userGift.points,
          'roomieId': userId,
          'isRealized': false,
          'boughtDate': DateTime.now().toIso8601String()
        }).then((documentSnapshot) {
          userRoom.roomiesGift.add(UserGift(
              id: documentSnapshot.id,
              giftName: userGift.giftName,
              points: userGift.points,
              roomieId: userId,
              isRealized: false,
              boughtDate: DateTime.now(),
              realizedDate: null));
          var roomieIndex =
              myRoom.roomies.indexWhere((roomie) => roomie.id == userId);
          Roomie oldRoomie = myRoom.roomies[roomieIndex];
          Roomie updatedRoomie = Roomie(
              id: oldRoomie.id,
              userName: oldRoomie.userName,
              points: pointsActual,
              imageUrl: oldRoomie.imageUrl);
          myRoom.roomies[roomieIndex] = updatedRoomie;
          notifyListeners();
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'points': pointsActual});
    }
  }

  List<UserGift> getUserGifts(String userId) {
    //POPRAWIONE
    return userRoom.roomiesGift
        .where((roomieGift) => roomieGift.roomieId == userId)
        .toList();
  }

  Future<void> markUserGiftAsRecived(String userId, String giftId) async {
    //POPRAWIONE
    DateTime dateNow = DateTime.now();

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(userRoom.id)
        .collection('roomiesGifts')
        .doc(giftId)
        .update(
            {'isRealized': true, 'realizedDate': dateNow.toIso8601String()});

    var giftIndex =
        userRoom.roomiesGift.indexWhere((gift) => gift.id == giftId);

    UserGift editedGift = userRoom.roomiesGift[giftIndex];

    UserGift newGift = UserGift(
        id: editedGift.id,
        giftName: editedGift.giftName,
        points: editedGift.points,
        roomieId: editedGift.roomieId,
        isRealized: true,
        boughtDate: editedGift.boughtDate,
        realizedDate: dateNow);
    userRoom.roomiesGift[giftIndex] = newGift;
    notifyListeners();
  }

  List<UserActivity> getRoomActivitiesByDate(DateTime date) {
    //POPRAWIONE
    List<UserActivity> activitiesAtDay = [];

    if (userRoom != null) {
      activitiesAtDay = userRoom.roomiesActivites
          .where((activity) => _compareDates(activity.creationDate, date))
          .toList();
      activitiesAtDay
          .sort(((a, b) => b.creationDate.compareTo(a.creationDate)));
    }
    return activitiesAtDay;
  }

  bool _compareDates(DateTime date1, DateTime date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    if (date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> getUsernameFromId(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    Map<String, dynamic> userData = userSnapshot.data();
    if (userData != null) {
      return userData['username'];
    } else {
      return '';
    }
  }
}
