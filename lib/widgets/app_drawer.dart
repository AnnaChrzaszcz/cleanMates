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
                      child: Hero(
                        tag: 'profile-pic',
                        child: CircleAvatar(
                          backgroundColor: Color.fromRGBO(247, 219, 79, 1),
                          radius: 30,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                FirebaseAuth.instance.currentUser.photoURL),
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
            title: Text('Dashboard'),
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
              title: Text('Room'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(UserRoomScreen.routeName);
              },
            ),
          if (room != null) const Divider(),
          // if (room != null)
          //   ListTile(
          //     leading: Icon(Icons.clean_hands),
          //     title: Text('Activities Overview'),
          //     onTap: () {
          //       //TYLKO JESLI JEST ROOM
          //       Navigator.of(context).pushNamed(ActivitiesScreen.routeName);
          //     },
          //   ),
          // if (room != null) Divider(),
          // if (room != null)
          //   ListTile(
          //     leading: Icon(Icons.card_giftcard_outlined),
          //     title: Text('Gifts Overview'), //TYLKO JESLI JEST ROOM
          //     onTap: () {
          //       Navigator.of(context).pushNamed(GiftsScreen.routeName);
          //     },
          //   ),
          // if (room != null) const Divider(),
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

                  title: Text('Requested gifts', style: TextStyle()),

                  //TYLKO JESLI JEST ROOM
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(RecivedGiftsScreen.routeName);
                  },
                ),
                if (roomieBoughtGifts != null && roomieBoughtGifts > 0)
                  Positioned(
                    right: 65,
                    child: CircleAvatar(
                      child: Text(
                        '${roomieBoughtGifts}',
                        style: TextStyle(fontSize: 13),
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
