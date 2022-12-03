import 'package:clean_mates_app/widgets/room_item_container.dart';
import 'package:flutter/material.dart';
import '../repositories/room_repository.dart';
import '../models/room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'room_item.dart';

class JoinRoom extends StatelessWidget {
  final void Function(Room room) joinRoom;
  JoinRoom(@required this.joinRoom);
  final roomRepo = RoomRepository();

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: roomRepo.getAllRooms(user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              print('mam data');
              List<Room> rooms = snapshot.data;
              if (rooms.length == 0) {
                return Center(child: Text('no available rooms'));
              }
              return RoomItemContainer(rooms, joinRoom);
            } else if (snapshot.hasError) {
              return Center(child: Text('no available rooms'));
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Container();
        });
  }
}
