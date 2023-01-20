import 'package:flutter/material.dart';

class Gift {
  final String id;
  final String giftName;
  final int points;
  final String roomId;
  final int iconCode;

  Gift(
      {@required this.id,
      @required this.giftName,
      @required this.points,
      @required this.roomId,
      @required this.iconCode});
}
