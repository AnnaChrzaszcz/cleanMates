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
                  ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(UserProfile.routeName,
                            arguments: {'user': user});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 5, bottom: 10),
                        child: Hero(
                          tag: 'profile-pic',
                          child: CircleAvatar(
                            backgroundColor:
                                const Color.fromRGBO(247, 219, 79, 1),
                            radius: 30,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  FirebaseAuth.instance.currentUser.photoURL),
                            ),
                          ),
                        ),
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
            leading: Icon(
              Icons.dashboard,
              color: ModalRoute.of(context).settings.name ==
                      UserDashboardScreen.routeName
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserDashboardScreen.routeName);
            },
          ),
          const Divider(),
          if (room != null)
            ListTile(
              leading: Icon(
                Icons.apartment,
                color: ModalRoute.of(context).settings.name ==
                        UserRoomScreen.routeName
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              title: const Text('Room'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(UserRoomScreen.routeName);
              },
            ),
          if (room != null) const Divider(),
          if (room != null)
            Stack(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.handshake,
                    color: ModalRoute.of(context).settings.name ==
                            RecivedGiftsScreen.routeName
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  title: const Text('Requested gifts', style: TextStyle()),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(RecivedGiftsScreen.routeName);
                  },
                ),
                if (roomieBoughtGifts != null && roomieBoughtGifts > 0)
                  Positioned(
                    right: 65,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      child: Text(
                        '$roomieBoughtGifts',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          if (room != null) const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
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
