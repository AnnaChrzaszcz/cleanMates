import 'package:clean_mates_app/widgets/room_dash.dart';

import '../repositories/room_repository.dart';
import 'package:clean_mates_app/screens/create_room_screen.dart';
import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomDashboardScreen extends StatelessWidget {
  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
        ),
        drawer: AppDrawer(),
        body: Center(
          child: RoomDash(),
        ));
  }
}
