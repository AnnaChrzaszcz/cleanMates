import 'package:clean_mates_app/screens/create_room_screen.dart';
import 'package:clean_mates_app/widgets/join_room.dart';
import 'package:clean_mates_app/widgets/roomie_item.dart';
import 'package:flutter/material.dart';
import '../repositories/room_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room.dart';

class RoomDash extends StatefulWidget {
  @override
  State<RoomDash> createState() => _RoomDashState();
}

class _RoomDashState extends State<RoomDash> {
  final user = FirebaseAuth.instance.currentUser;
  final roomRepo = RoomRepository();
  var _joinRoom = false;
  List<Room> availableRooms = [];

  void _joinToRoom(Room selectedRoom) {
    roomRepo.joinToRoom(selectedRoom).then((_) {
      setState(() {});
    });
  }

  void _leaveRoom(Room actualRoom) {
    roomRepo.leaveRoom(actualRoom).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: roomRepo.getYourRoom(user),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            Room room = snapshot.data;
            print(room.roomies[0].imageUrl);
            return Container(
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
                          room.roomies[index].userName,
                          room.roomies[index].imageUrl,
                          room.roomies[index].points)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _leaveRoom(room),
                    child: Text('Leave this room'),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              width: double.infinity,
              height: 700,
              // decoration:
              //     BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              child: Column(
                children: [
                  ElevatedButton(
                    child: Text('Create new room'),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(CreateRoomScreen.routeName)
                          .then((value) {
                        setState(() {});
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _joinRoom = !_joinRoom;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Join existing room',
                          style: TextStyle(
                              color: Color.fromRGBO(47, 149, 153, 1),
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
                        Icon(!_joinRoom ? Icons.expand_more : Icons.expand_less)
                      ],
                    ),
                  ),
                  if (_joinRoom) JoinRoom(_joinToRoom)
                ],
              ),
            );
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }
}
