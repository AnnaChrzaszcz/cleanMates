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
          title: Text(room.roomName),
          leading: Icon(
            Icons.house,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).iconTheme.color,
            size: 40,
          ),
          subtitle: Text('owner: ${room.creatorId}'),
          trailing: const Icon(
            Icons.check_rounded,
            size: 30,
          ),
          onTap: () => select(index),
          selected: isSelected,
          selectedColor: Theme.of(context).primaryColor,
        ),
        const Divider(),
      ],
    );
  }
}
