import 'package:flutter/material.dart';
import '../models/activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitiesProvider extends ChangeNotifier {
  List<Activity> _activities;
  final user = FirebaseAuth.instance.currentUser;

  ActivitiesProvider(this._activities);

  List<Activity> get activities {
    return [..._activities];
  }

  Future<void> fetchAndSetData([String filterByRoomId]) async {
    List<Activity> activities = [];
    QuerySnapshot<Map<String, dynamic>> activitiesData;

    if (filterByRoomId != null) {
      activitiesData = await FirebaseFirestore.instance
          .collection('activities')
          .where('roomId', isEqualTo: filterByRoomId)
          .get();
    } else {
      activitiesData = await FirebaseFirestore.instance
          .collection('activities')
          .where(true)
          .get();
    }

    activitiesData.docs.forEach((element) {
      print(element['roomId']);
      Activity activity = Activity(
          id: element.id,
          activityName: element['activityName'],
          points: element['points'],
          roomId: element['roomId']);
      activities.add(activity);
    });
    activities.sort(((a, b) => a.activityName.compareTo(b.activityName)));
    _activities = activities;
    notifyListeners();
  }

  Future<void> addActivity(Activity activity, String idRoom) async {
    final newActivityRef =
        await FirebaseFirestore.instance.collection('activities').doc();

    // final roomRef =
    //     await FirebaseFirestore.instance.collection('rooms').doc(idRoom).get();

    await newActivityRef.set({
      'activityName': activity.activityName,
      'points': activity.points,
      'roomId': idRoom,
    });

    final newActivity = Activity(
        id: newActivityRef.id,
        activityName: activity.activityName,
        points: activity.points,
        roomId: activity.roomId);

    //_activities.insert(0, newActivity);
    _activities.add(newActivity);
    notifyListeners();
  }

  Future<void> updateActivity(String id, Activity newActivity) async {
    await FirebaseFirestore.instance.collection('activities').doc(id).update({
      'activityName': newActivity.activityName,
      'points': newActivity.points
    });

    final activityIndex =
        _activities.indexWhere((activity) => activity.id == id);
    if (activityIndex >= 0) {
      _activities[activityIndex] = newActivity;
      notifyListeners();
    } else {
      print('..');
    }
  }

  Future<void> deleteActivity(String id) async {
    final activityIndex =
        _activities.indexWhere((activity) => activity.id == id);
    var existingActivity = _activities[activityIndex];
    _activities.removeAt(activityIndex);
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(id)
          .delete();
    } catch (error) {
      _activities.insert(activityIndex, existingActivity);
      notifyListeners();
    }

    existingActivity = null;
  }

  Activity findById(String id) {
    return _activities.firstWhere((activity) => activity.id == id);
  }
}
