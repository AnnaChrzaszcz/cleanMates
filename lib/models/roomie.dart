import 'package:flutter/material.dart';

class Roomie {
  final String id;
  final String userName;
  final int points;
  final String imageUrl;

  Roomie({
    @required this.id,
    @required this.userName,
    @required this.points,
    @required this.imageUrl,
  });
}
