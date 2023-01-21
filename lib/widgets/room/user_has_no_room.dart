import 'package:clean_mates_app/providers/rooms_provider.dart';
import 'package:clean_mates_app/screens/user_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  List<Room> rooms = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<RoomsProvider>(context, listen: false)
        .getAvailableRooms()
        .then((availableRooms) => rooms = availableRooms);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    Provider.of<RoomsProvider>(context, listen: false)
        .getAvailableRooms()
        .then((availableRooms) => rooms = availableRooms);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      //decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You have currently no room',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 20),
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
          Text(
            'or',
            style: TextStyle(fontSize: 20),
          ),
          GestureDetector(
              onTap: () {
                setState(() {
                  _joinRoom = !_joinRoom;
                });
              },
              child: !_joinRoom
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Join existing room',
                          style: TextStyle(
                              color: Color.fromRGBO(47, 149, 153, 1),
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
                        Icon(Icons.chevron_right)
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.chevron_left),
                        Text(
                          'Create new room',
                          style: TextStyle(
                              color: Color.fromRGBO(47, 149, 153, 1),
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        ),
                      ],
                    )),
          if (_joinRoom) JoinRoom(widget.joinToRoom, rooms)
        ],
      ),
    );
  }
}
