import 'package:clean_mates_app/providers/rooms_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import 'room_item.dart';
import '../../repositories/room_repository.dart';

class RoomItemContainer extends StatefulWidget {
  final List<Room> rooms;
  final void Function(Room room) joinRoom;
  RoomItemContainer(@required this.rooms, @required this.joinRoom);

  @override
  _RoomItemConState createState() => _RoomItemConState();
}

class _RoomItemConState extends State<RoomItemContainer> {
  int _selectedIndex = -1;
  Room selectedRoom;

  void _selectRoom(index) {
    setState(() {
      selectedRoom = _selectedIndex == index ? null : widget.rooms[index];
      _selectedIndex = _selectedIndex == index ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.rooms.length,
              itemBuilder: ((context, index) {
                return RoomItem(
                  room: widget.rooms[index],
                  index: index,
                  isSelected: _selectedIndex == index ? true : false,
                  select: _selectRoom,
                );
              }),
            ),
          ),
          ElevatedButton(
            onPressed:
                _selectedIndex < 0 ? null : () => widget.joinRoom(selectedRoom),
            child: Text('Join'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled))
                    return Colors.grey;
                  return Theme.of(context)
                      .primaryColor; // Use the component's default.
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
