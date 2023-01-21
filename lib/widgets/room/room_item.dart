import 'package:flutter/material.dart';
import '../../models/room.dart';

class RoomItem extends StatelessWidget {
  final Room room;
  final int index;
  final bool isSelected;
  final void Function(int index) select;

  RoomItem({
    @required this.room,
    @required this.index,
    @required this.isSelected,
    @required this.select,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            room.roomName,
            style: TextStyle(color: Colors.black),
          ),
          leading: Icon(
            Icons.house_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
          subtitle: Text(
            'owner: ${room.creatorId}',
            style: TextStyle(color: Colors.black45),
          ),
          trailing: Icon(
            Icons.check_rounded,
            size: isSelected ? 30 : 0,
          ),
          onTap: () => select(index),
          selected: isSelected,
        ),
        const Divider(),
      ],
    );
  }
}
