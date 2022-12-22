import 'package:clean_mates_app/providers/rooms_provider.dart';
import 'package:clean_mates_app/widgets/room/room_item_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/room_repository.dart';
import '../../models/room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'room_item.dart';

class JoinRoom extends StatelessWidget {
  final void Function(Room room) joinRoom;
  List<Room> rooms;

  JoinRoom(@required this.joinRoom, @required this.rooms);

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return rooms.isEmpty
        ? Center(child: Text('no available rooms'))
        : RoomItemContainer(rooms, joinRoom);
  }
}
