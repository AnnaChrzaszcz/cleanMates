import 'package:flutter/material.dart';

class UserActivity {
  final String id;
  final String activityName;
  final int points;
  final String roomieId;
  //final String roomId;
  final DateTime creationDate;

  UserActivity(
      {@required this.id,
      @required this.activityName,
      @required this.points,
      @required this.roomieId,
      //this.roomId,
      @required this.creationDate});
}
