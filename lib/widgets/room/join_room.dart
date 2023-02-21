import 'package:clean_mates_app/widgets/room/room_item_container.dart';
import 'package:flutter/material.dart';
import '../../models/room.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinRoom extends StatelessWidget {
  final void Function(Room room) joinRoom;
  List<Room> rooms;

  JoinRoom(@required this.joinRoom, @required this.rooms);

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return rooms.isEmpty
        ? const Center(child: Text('no available rooms'))
        : RoomItemContainer(rooms, joinRoom);
  }
}
