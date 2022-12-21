import 'package:clean_mates_app/models/gift.dart';
import 'package:flutter/material.dart';

class UserGift {
  final String id;
  final String roomieId;
  final String giftName;
  final int points;
  final bool isRealized;
  final DateTime boughtDate;
  final DateTime realizedDate;

  UserGift(
      {@required this.id,
      @required this.giftName,
      @required this.points,
      //@required this.gift,
      @required this.roomieId,
      @required this.isRealized,
      @required this.boughtDate,
      @required this.realizedDate});
}
