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
    Provider.of<RoomsProvider>(ctx, listen: false)
        .leaveRoom(actualRoom.id)
        .then((_) {});
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
        room = Provider.of<RoomsProvider>(context).myRoom;
      });
    }

    return room == null
        ? UserDashboardScreen()
        : Scaffold(
            appBar: AppBar(title: Text('Your room')),
            drawer: AppDrawer(), // jak to zastapic strzalka do tylu
            body: Container(
              width: double.infinity,
              height: 600,
              decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
              child: Column(
                children: [
                  Text(
                    room.roomName,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Expanded(
                    child: CustomRefreshIndicator(
                      builder: MaterialIndicatorDelegate(
                        builder: (context, controller) {
                          return const CircleAvatar(
                            radius: 55,
                            backgroundColor: Color.fromRGBO(247, 219, 79, 1),
                            child: RiveAnimation.asset(
                              'assets/animations/indicator.riv',
                            ),
                          );
                        },
                      ),
                      onRefresh: _refreshRoom,
                      child: ListView.builder(
                        itemCount: roomies.length,
                        itemBuilder: ((context, index) => RoomieItem(
                            roomies[index].id,
                            roomies[index].userName,
                            roomies[index].imageUrl,
                            roomies[index].points)),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _leaveRoom(room, context),
                    child: Text('Leave this room'),
                  ),
                ],
              ),
            ),
          );
  }
}
