import 'package:flutter/material.dart';
import '../models/room.dart';
import '../widgets/room_item.dart';
import '../repositories/room_repository.dart';

class RoomItemContainer extends StatefulWidget {
  final List<Room> rooms;
  final void Function(Room room) joinRoom;
  RoomItemContainer(@required this.rooms, @required this.joinRoom);

  @override
  _RoomItemConState createState() => _RoomItemConState();
}

class _RoomItemConState extends State<RoomItemContainer> {
  int _selectedIndex = -1;
  final roomRepo = RoomRepository();
  Room selectedRoom;

  void _selectRoom(index) {
    setState(() {
      selectedRoom = _selectedIndex == index ? null : widget.rooms[index];
      _selectedIndex = _selectedIndex == index ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 500,
          //decoration: BoxDecoration(border: Border.all(color: Colors.yellow)),
          child: ListView.builder(
            itemCount: widget.rooms.length,
            itemBuilder: ((context, index) => RoomItem(
                  room: widget.rooms[index],
                  index: index,
                  isSelected: _selectedIndex == index ? true : false,
                  select: _selectRoom,
                )),
          ),
        ),
        ElevatedButton(
          onPressed:
              _selectedIndex < 0 ? null : () => widget.joinRoom(selectedRoom),
          child: Text('Join'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) return Colors.grey;
                return Theme.of(context)
                    .primaryColor; // Use the component's default.
              },
            ),
          ),
        )
      ],
    );
  }
}
