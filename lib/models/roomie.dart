import 'package:flutter/material.dart';
import '../models/activity.dart';

class Roomie {
  final String id;
  final String userName;
  final int points;
  final String imageUrl;
  final List<Activity> activities;

  Roomie(
      {@required this.id,
      @required this.userName,
      @required this.points,
      @required this.imageUrl,
      this.activities});
}
