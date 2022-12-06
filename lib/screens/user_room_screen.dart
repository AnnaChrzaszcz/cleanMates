import 'package:clean_mates_app/screens/user_dashboard_screen.dart';
import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import '../models/room.dart';
import '../widgets/roomie_item.dart';
import '../repositories/room_repository.dart';
import 'package:provider/provider.dart';
import '../providers/rooms_provider.dart';

class UserRoomScreen extends StatelessWidget {
  static const String routeName = '/userRoom';
  final roomRepo = RoomRepository();

  void _leaveRoom(Room actualRoom, BuildContext ctx) {
    Provider.of<RoomsProvider>(ctx, listen: false)
        .leaveRoom(actualRoom)
        .then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final room = Provider.of<RoomsProvider>(context).myRoom;

    return room == null
        ? UserDashboardScreen()
        : Scaffold(
            appBar: AppBar(title: Text('Your room')),
            //drawer: AppDrawer(),
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
                    child: ListView.builder(
                      itemCount: room.roomies.length,
                      itemBuilder: ((context, index) => RoomieItem(
                          room.roomies[index].id,
                          room.roomies[index].userName,
                          room.roomies[index].imageUrl,
                          room.roomies[index].points)),
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
