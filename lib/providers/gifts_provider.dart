import '../models/gift.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GiftsProvider extends ChangeNotifier {
  List<Gift> _gifts;
  final user = FirebaseAuth.instance.currentUser;

  GiftsProvider(this._gifts);

  List<Gift> get gifts {
    return [..._gifts];
  }

  Future<void> fetchAndSetData([String filterByRoomId]) async {
    List<Gift> gifts = [];
    QuerySnapshot<Map<String, dynamic>> giftsData;

    if (filterByRoomId != null) {
      giftsData = await FirebaseFirestore.instance
          .collection('gifts')
          .where('roomId', isEqualTo: filterByRoomId)
          .get();
    } else {
      giftsData = await FirebaseFirestore.instance.collection('gifts').get();
    }

    giftsData.docs.forEach((element) {
      Gift gift = Gift(
        id: element.id,
        giftName: element['giftName'],
        points: element['points'],
        roomId: element['roomId'],
      );
      gifts.add(gift);
    });
    _gifts = gifts;
    notifyListeners();
  }

  Future<void> addGift(Gift gift, String idRoom) async {
    final newGiftRef =
        await FirebaseFirestore.instance.collection('gifts').doc();

    await newGiftRef.set({
      'giftName': gift.giftName,
      'points': gift.points,
      'roomId': idRoom,
    });

    final newGift = Gift(
        id: newGiftRef.id,
        giftName: gift.giftName,
        points: gift.points,
        roomId: gift.roomId);

    _gifts.add(newGift);

    notifyListeners();
  }

  Future<void> updateGift(String id, Gift newGift) async {
    await FirebaseFirestore.instance
        .collection('gifts')
        .doc(id)
        .update({'giftName': newGift.giftName, 'points': newGift.points});

    final giftIndex = _gifts.indexWhere((gift) => gift.id == id);
    if (giftIndex >= 0) {
      _gifts[giftIndex] = newGift;
      notifyListeners();
    } else {
      print('..');
    }
  }

  Future<void> deleteGift(String id) async {
    final giftIndex = _gifts.indexWhere((gift) => gift.id == id);
    var existingGift = _gifts[giftIndex];
    _gifts.removeAt(giftIndex);
    notifyListeners();
    try {
      await FirebaseFirestore.instance.collection('gifts').doc(id).delete();
    } catch (error) {
      _gifts.insert(giftIndex, existingGift);
      notifyListeners();
    }

    existingGift = null;
  }

  Gift findById(String id) {
    return _gifts.firstWhere((gift) => gift.id == id);
  }
}
