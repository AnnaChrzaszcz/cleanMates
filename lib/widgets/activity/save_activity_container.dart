import 'dart:ffi';

import 'package:clean_mates_app/models/userActivity.dart';
import 'package:clean_mates_app/screens/gratification_activity_screen.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../models/activity.dart';
import '../../providers/rooms_provider.dart';
import 'package:provider/provider.dart';

class SaveActivityContainer extends StatefulWidget {
  final List<Activity> activities;
  final String userId;
  Function refreshActovoties;
  SaveActivityContainer(@required this.activities, @required this.userId,
      @required this.refreshActovoties);

  @override
  _SaveActivityContainerState createState() => _SaveActivityContainerState();
}

class _SaveActivityContainerState extends State<SaveActivityContainer> {
  var selectedIndexes = [];
  var activitesPointsSum = 0;
  var _isLoading = false;

  void _saveActivites() async {
    setState(() {
      _isLoading = true;
    });
    List<UserActivity> selectedUserActivities = [];
    selectedIndexes.forEach((index) {
      Activity selActivity = widget.activities[index];
      UserActivity newUserActivity = UserActivity(
          id: null,
          activityName: selActivity.activityName,
          points: selActivity.points,
          roomieId: widget.userId,
          creationDate: null);
      selectedUserActivities.add(newUserActivity);
    });
    try {
      await Provider.of<RoomsProvider>(context, listen: false)
          .addActivitiesToRoomie(
              selectedUserActivities, widget.userId, activitesPointsSum);

      var username = await Provider.of<RoomsProvider>(context, listen: false)
          .getUsernameFromId(widget.userId);

      print(username);

      Navigator.of(context).pushReplacementNamed(
          GratificationActivityScreen.routeName,
          arguments: {'points': activitesPointsSum, 'username': username});
    } catch (err) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occured'),
          content: Text('Sth went wrong'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Okay'),
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            child: AnimatedSwitcher(
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              duration: const Duration(milliseconds: 600),
              child: Text(
                '${activitesPointsSum}',
                key: ValueKey<int>(activitesPointsSum),
              ),
            ),
          ),
          Expanded(
            child: CustomRefreshIndicator(
              builder: MaterialIndicatorDelegate(
                builder: (context, controller) {
                  return const CircleAvatar(
                    radius: 55,
                    backgroundColor: Color.fromRGBO(47, 149, 153, 1),
                    child: RiveAnimation.asset(
                      'assets/animations/indicator.riv',
                    ),
                  );
                },
              ),
              onRefresh: () => widget.refreshActovoties(),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                child: ListView.builder(
                  itemCount: widget.activities.length,
                  itemBuilder: ((context, index) => Column(
                        children: [
                          CheckboxListTile(
                            title: Text(
                              widget.activities[index].activityName,
                              style: TextStyle(
                                  fontWeight: selectedIndexes.contains(index)
                                      ? FontWeight.w500
                                      : FontWeight.normal),
                            ),
                            secondary: CircleAvatar(
                              radius: selectedIndexes.contains(index) ? 23 : 22,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: CircleAvatar(
                                radius: 20,
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                child: Text(
                                  '${widget.activities[index].points}',
                                  style: TextStyle(
                                      fontWeight:
                                          selectedIndexes.contains(index)
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                ),
                              ),
                            ),
                            value: selectedIndexes.contains(index),
                            onChanged: (_) {
                              if (selectedIndexes.contains(index)) {
                                setState(() {
                                  selectedIndexes.remove(index);
                                  activitesPointsSum -=
                                      widget.activities[index].points;
                                });
                              } else {
                                setState(() {
                                  selectedIndexes.add(index);
                                  activitesPointsSum +=
                                      widget.activities[index].points;
                                });
                              }
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                            tileColor: selectedIndexes.contains(index)
                                ? Colors.grey[100]
                                : Colors.white,
                          ),
                          Divider()
                        ],
                      )),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed:
                selectedIndexes.length <= 0 ? null : () => _saveActivites(),
            child: _isLoading ? CircularProgressIndicator() : Text('Save'),
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
