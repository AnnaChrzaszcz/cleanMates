import 'package:clean_mates_app/models/roomie.dart';
import 'package:clean_mates_app/screens/user_dashboard_screen.dart';
import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../models/room.dart';
import '../widgets/room/roomie_item.dart';

import 'package:provider/provider.dart';
import '../providers/rooms_provider.dart';

class UserRoomScreen extends StatelessWidget {
  static const String routeName = '/userRoom';

  void _leaveRoom(Room actualRoom, BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('You will lost all your points'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('NO')),
          TextButton(
              onPressed: () {
                Provider.of<RoomsProvider>(ctx, listen: false)
                    .leaveRoom(actualRoom.id);
                Navigator.of(ctx).pop();
              },
              child: Text('YES')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser.uid;
    Room room = Provider.of<RoomsProvider>(context).myRoom;
    List<Roomie> roomies = [];
    if (room != null) {
      roomies = [
        room.roomies.firstWhere((roomie) => roomie.id == userId),
      ];
      if (room.roomies.length == 2) {
        roomies.add(room.roomies.firstWhere((roomie) => roomie.id != userId));
      }
    }

    Future<void> _refreshRoom() async {
      Provider.of<RoomsProvider>(context, listen: false)
          .getUserRoom(userId)
          .then((value) {
        room = Provider.of<RoomsProvider>(context, listen: false).myRoom;
      });
    }

    return room == null
        ? UserDashboardScreen()
        : Scaffold(
            appBar: AppBar(title: Text(room != null ? room.roomName : '')),
            drawer: AppDrawer(), // jak to zastapic strzalka do tylu
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 25),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomRefreshIndicator(
                      builder: MaterialIndicatorDelegate(
                        builder: (context, controller) {
                          return const CircleAvatar(
                            radius: 60,
                            backgroundColor: Color.fromRGBO(47, 149, 153, 1),
                            child: RiveAnimation.asset(
                              'assets/animations/indicator.riv',
                            ),
                          );
                        },
                      ),
                      onRefresh: _refreshRoom,
                      child: Center(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: roomies.length,
                          itemBuilder: ((context, index) => RoomieItem(
                              roomies[index].id,
                              roomies[index].userName,
                              roomies[index].imageUrl,
                              roomies[index].points)),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _leaveRoom(room, context),
                    child: Text('Leave this room'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          );
  }
}
