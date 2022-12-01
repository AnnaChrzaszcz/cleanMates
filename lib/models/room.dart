import 'package:flutter/material.dart';
import './roomie.dart';

class Room {
  final String id;
  final String roomName;
  final String creatorId;
  final List<Roomie> roomies;
  // final DateTime dateTime;
  // final String creatorId;

  Room({
    @required this.id,
    @required this.roomName,
    @required this.creatorId,
    @required this.roomies,
    // @required this.dateTime,
    // @required this.creatorId
  });
}
