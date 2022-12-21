import 'package:clean_mates_app/models/userActivity.dart';
import 'package:clean_mates_app/models/userGift.dart';
import 'package:flutter/material.dart';
import './roomie.dart';

class Room {
  final String id;
  final String roomName;
  final String creatorId;
  final List<Roomie> roomies;
  final List<UserActivity> roomiesActivites;
  final List<UserGift> roomiesGift;
  // final DateTime dateTime;

  Room(
      {@required this.id,
      @required this.roomName,
      @required this.creatorId,
      @required this.roomies,
      @required this.roomiesActivites,
      @required this.roomiesGift
      // @required this.dateTime,
      });
}
