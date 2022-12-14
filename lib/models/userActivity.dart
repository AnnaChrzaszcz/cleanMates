import 'package:flutter/material.dart';

class UserActivity {
  final String id;
  final String activityName;
  final int points;
  final String userId;
  final String roomId;
  final DateTime creationDate;

  UserActivity(this.id, this.activityName, this.points, this.userId,
      this.roomId, this.creationDate);
}
