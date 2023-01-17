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
  List<Room> rooms;
  TextEditingController _textEditingController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rooms = widget.rooms;
    _textEditingController = TextEditingController();
    _textEditingController.addListener(_filterList);
  }

  void _filterList() {
    setState(() {
      rooms = widget.rooms
          .where((room) => room.roomName
              .toLowerCase()
              .contains(_textEditingController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

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
          Container(
            height: 40.0,
            width: 300.0,
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            child: TextField(
              controller: _textEditingController,
              cursorRadius: const Radius.circular(10.0),
              cursorWidth: 2.0,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: 'Search...',
                labelStyle: const TextStyle(
                  color: Color(0xff5B5B5B),
                  fontSize: 17.0,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.all(8),
                icon: Icon(Icons.search),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide()),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: ((context, index) {
                return RoomItem(
                  room: rooms[index],
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
                      .colorScheme
                      .primary; // Use the component's default.
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
