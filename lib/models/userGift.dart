import 'package:clean_mates_app/models/gift.dart';
import 'package:flutter/material.dart';

class UserGift {
  final String id;
  final Gift gift;
  final String userId;
  final bool isRealized;
  final DateTime boughtDate;
  final DateTime realizedDate;

  UserGift(
      {@required this.id,
      @required this.gift,
      @required this.userId,
      this.isRealized,
      this.boughtDate,
      this.realizedDate});
}
