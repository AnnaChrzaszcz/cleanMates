import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String activityName;
  final int points;
  //final String creatorId;
  final String roomId;

  Activity(
      {@required this.id,
      @required this.activityName,
      @required this.points,
      @required this.roomId
      // @required this.dateTime,
      // @required this.creatorId
      });
}
