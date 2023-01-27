import 'package:clean_mates_app/screens/activities_screen.dart';
import 'package:clean_mates_app/screens/gifts_screen.dart';
import 'package:clean_mates_app/screens/gifts_reception_screen.dart';
import 'package:clean_mates_app/screens/user_profile_screen.dart';
import 'package:clean_mates_app/screens/user_room_screen.dart';

import '../screens/user_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/rooms_provider.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  var roomieBoughtGifts;

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    final room = Provider.of<RoomsProvider>(context, listen: false).myRoom;
    roomieBoughtGifts = room != null
        ? room.roomiesGift
            .where((gift) => gift.roomieId != user.uid)
            .where((gift) => gift.isRealized == false)
            .length
        : null;

    return Drawer(
      width: 260,
      child: Column(
        children: [
          AppBar(
            actions: [
              FirebaseAuth.instance.currentUser != null
                  ? Container(
                      margin: EdgeInsets.only(right: 5, bottom: 10),
                      child: CircleAvatar(
                        backgroundColor: Color.fromRGBO(247, 219, 79, 1),
                        radius: 30,
                        child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                FirebaseAuth.instance.currentUser.photoURL)),
                      ),
                    )
                  : Container()
            ],
            title: Text(FirebaseAuth.instance.currentUser != null
                ? FirebaseAuth.instance.currentUser.displayName
                : ''),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserDashboardScreen.routeName);
            },
          ),
          const Divider(),
          if (room != null)
            ListTile(
              leading: const Icon(Icons.apartment),
              title: Text('Room'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(UserRoomScreen.routeName);
              },
            ),
          if (room != null) const Divider(),
          if (room != null)
            Stack(
              children: [
                if (room != null)
                  ListTile(
                    leading: Icon(Icons.handshake),
                    title: Text('Gifts Reception'), //TYLKO JESLI JEST ROOM
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(RecivedGiftsScreen.routeName);
                    },
                  ),
                if (roomieBoughtGifts != null && roomieBoughtGifts > 0)
                  Positioned(
                    right: 75,
                    child: CircleAvatar(
                      child: Text(
                        '${roomieBoughtGifts}',
                      ),
                      radius: 12,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          if (room != null) const Divider(),
          if (room != null)
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'), //TYLKO JESLI JEST ROOM
              onTap: () {
                Navigator.of(context).pushNamed(UserProfile.routeName,
                    arguments: {'user': user});
              },
            ),
          if (room != null) const Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<RoomsProvider>(context, listen: false).userRoom =
                  null;
              FirebaseAuth.instance.signOut();
            },
          ),
          if (room != null) const Divider(),
        ],
      ),
    );
  }
}
