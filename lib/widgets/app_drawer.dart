import 'package:clean_mates_app/screens/activities_screen.dart';

import '../screens/user_dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room.dart';
import '../screens/user_room_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      width: 260,
      child: Column(
        children: [
          AppBar(
            actions: [
              Container(
                margin: EdgeInsets.only(right: 5, bottom: 10),
                child: CircleAvatar(
                  backgroundColor: Color.fromRGBO(247, 219, 79, 1),
                  radius: 30,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        FirebaseAuth.instance.currentUser.photoURL),
                  ),
                ),
              )
            ],
            title: Text(FirebaseAuth.instance.currentUser.displayName),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                  UserDashboardScreen.routeName,
                  arguments: {
                    'name': user.displayName,
                    'imageUrl': user.photoURL,
                    'points': 0,
                  });
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              //   Navigator.of(context)
              //       .pushReplacementNamed(UserRoomScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.clean_hands),
            title: Text('Activities'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ActivitiesScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
