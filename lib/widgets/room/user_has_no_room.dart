import 'package:clean_mates_app/screens/user_room_screen.dart';
import 'package:flutter/material.dart';
import '../../screens/create_room_screen.dart';
import '../../repositories/room_repository.dart';
import '../../models/room.dart';
import 'join_room.dart';

class UserHasNoRoom extends StatefulWidget {
  final void Function(Room room) joinToRoom;
  final void Function() createdRoom;

  UserHasNoRoom(@required this.joinToRoom, @required this.createdRoom);

  @override
  State<UserHasNoRoom> createState() => _UserHasNoRoomState();
}

class _UserHasNoRoomState extends State<UserHasNoRoom> {
  final roomRepo = RoomRepository();
  var _joinRoom = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      //decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You have currently no room',
            style: Theme.of(context).textTheme.headline6,
          ),
          ElevatedButton(
            child: Text('Create new room'),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(CreateRoomScreen.routeName)
                  .then((_) {
                widget.createdRoom;
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
          if (_joinRoom) JoinRoom(widget.joinToRoom)
        ],
      ),
    );
  }
}
