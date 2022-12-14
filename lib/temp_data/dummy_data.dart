import 'package:clean_mates_app/models/gift.dart';
import 'package:clean_mates_app/models/userGift.dart';
import 'package:flutter/material.dart';

List<Gift> DUMMY_GIFTS = [
  Gift(
      id: DateTime.now().toString(),
      giftName: 'Prezent',
      points: 50,
      roomId: '1'),
  Gift(
      id: DateTime.now().toString(),
      giftName: 'Masaz',
      points: 10,
      roomId: '1'),
  Gift(
      id: DateTime.now().toString(),
      giftName: 'Piwko',
      points: 100,
      roomId: '1'),
  Gift(
      id: DateTime.now().toString(),
      giftName: 'Sniadanko',
      points: 200,
      roomId: '1'),
  Gift(
      id: DateTime.now().toString(),
      giftName: 'Kupa',
      points: 500,
      roomId: '1'),
];

List<UserGift> DUMMY_USER_GIFTS = [
  UserGift(
      id: DateTime.now().toString(),
      gift: DUMMY_GIFTS[0],
      userId: 'you',
      isRealized: false,
      boughtDate: DateTime.now(),
      realizedDate: null),
  UserGift(
      id: DateTime.now().toString(),
      userId: 'you',
      gift: DUMMY_GIFTS[0],
      isRealized: true,
      boughtDate: DateTime.now(),
      realizedDate: DateTime.now()),
  UserGift(
      id: DateTime.now().toString(),
      userId: 'roomie',
      gift: DUMMY_GIFTS[0],
      isRealized: true,
      boughtDate: DateTime.now(),
      realizedDate: DateTime.now()),
  UserGift(
      id: DateTime.now().toString(),
      userId: 'you',
      gift: DUMMY_GIFTS[1],
      isRealized: false,
      boughtDate: DateTime.now(),
      realizedDate: null),
  UserGift(
      id: DateTime.now().toString(),
      userId: 'roomie',
      gift: DUMMY_GIFTS[2],
      isRealized: false,
      boughtDate: DateTime.now(),
      realizedDate: null),
  UserGift(
      id: DateTime.now().toString(),
      userId: 'roomie',
      gift: DUMMY_GIFTS[3],
      isRealized: true,
      boughtDate: DateTime.now(),
      realizedDate: DateTime.now()),
  UserGift(
      id: DateTime.now().toString(),
      userId: 'you',
      gift: DUMMY_GIFTS[1],
      isRealized: false,
      boughtDate: DateTime.now(),
      realizedDate: null),
  UserGift(
      id: DateTime.now().toString(),
      userId: 'you',
      gift: DUMMY_GIFTS[0],
      isRealized: false,
      boughtDate: DateTime.now(),
      realizedDate: null),
  UserGift(
      id: DateTime.now().toString(),
      userId: 'roomie',
      gift: DUMMY_GIFTS[4],
      isRealized: true,
      boughtDate: DateTime.now(),
      realizedDate: DateTime.now()),
  UserGift(
      userId: 'you',
      id: DateTime.now().toString(),
      gift: DUMMY_GIFTS[3],
      isRealized: false,
      boughtDate: DateTime.now(),
      realizedDate: null),
  UserGift(
      userId: 'you',
      id: DateTime.now().toString(),
      gift: DUMMY_GIFTS[2],
      isRealized: true,
      boughtDate: DateTime.now(),
      realizedDate: DateTime.now()),
];
