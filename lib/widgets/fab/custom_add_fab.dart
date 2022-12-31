import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/screens/edit_gift_screen.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

const double fabSize = 56;

class CustomAddFab extends StatelessWidget {
  final String roomId;
  final bool activityScreen;

  CustomAddFab({this.roomId, this.activityScreen});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionDuration: Duration(milliseconds: 500),
      openBuilder: (context, _) {
        return activityScreen
            ? EditActivityScreen(roomId: roomId)
            : EditGiftScreen(roomId: roomId);
      },
      closedShape: CircleBorder(),
      closedColor: Theme.of(context).colorScheme.primary,
      closedBuilder: (context, OpenContainer) => Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary),
          height: fabSize,
          width: fabSize,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          )),
    );
  }
}
