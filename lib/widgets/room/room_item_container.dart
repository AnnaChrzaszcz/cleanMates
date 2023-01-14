import 'dart:math';
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

class _RoomItemConState extends State<RoomItemContainer>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = -1;
  Room selectedRoom;
  List<Room> rooms;
  int toggle = 0;
  AnimationController _con;
  TextEditingController _textEditingController;
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    _textEditingController = TextEditingController();
    rooms = widget.rooms;
    _con = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 375),
    );
    _textEditingController.addListener(_filterList);
    super.initState();
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
            height: 100,
            width: 250,
            alignment: const Alignment(-1.0, 0.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 375),
              height: 48.0,
              width: (toggle == 0) ? 48.0 : 250.0,
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: -10.0,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 375),
                    left: (toggle == 0) ? 20.0 : 40.0,
                    curve: Curves.easeOut,
                    top: 11.0,
                    child: AnimatedOpacity(
                      opacity: (toggle == 0) ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        height: 23.0,
                        width: 180.0,
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
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 375),
                    left: 4,
                    top: 4,
                    child: IconButton(
                      splashRadius: 19.0,
                      icon: const Icon(
                        Icons.search,
                        size: 24.0,
                      ),
                      onPressed: () {
                        setState(() {
                          if (toggle == 0) {
                            toggle = 1;
                            _con.forward();
                          } else {
                            toggle = 0;
                            _textEditingController.clear();
                            _con.reverse();
                          }
                        });
                      },
                    ),
                  )
                ],
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
