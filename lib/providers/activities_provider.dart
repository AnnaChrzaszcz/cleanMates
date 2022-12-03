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

  Future<void> fetchAndSetData() async {
    List<Activity> activities = [];
    QuerySnapshot<Map<String, dynamic>> activitiesData =
        await FirebaseFirestore.instance.collection('activities').get();
    activitiesData.docs.forEach((element) {
      Activity activity = Activity(
          id: element.id,
          activityName: element['activityName'],
          points: element['points']);
      activities.add(activity);
    });
    _activities = activities;
    notifyListeners();
  }

  Future<void> addActivity(Activity activity) async {
    final newActivityRef =
        await FirebaseFirestore.instance.collection('activities').doc();

    await newActivityRef.set(
        {'activityName': activity.activityName, 'points': activity.points});

    final newActivity = Activity(
        id: newActivityRef.id,
        activityName: activity.activityName,
        points: activity.points);

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

  Activity findById(String id) {
    return _activities.firstWhere((activity) => activity.id == id);
  }
}
