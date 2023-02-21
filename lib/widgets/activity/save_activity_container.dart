import 'dart:ffi';

import 'package:clean_mates_app/models/userActivity.dart';
import 'package:clean_mates_app/providers/activities_provider.dart';
import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/screens/gratification_activity_screen.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../models/activity.dart';
import '../../providers/rooms_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  var activitiesLength = 0;

  void _saveActivites() async {
    setState(() {
      _isLoading = true;
    });
    List<UserActivity> selectedUserActivities = [];
    for (var index in selectedIndexes) {
      Activity selActivity = widget.activities[index];
      UserActivity newUserActivity = UserActivity(
          id: null,
          activityName: selActivity.activityName,
          points: selActivity.points,
          roomieId: widget.userId,
          creationDate: null);
      selectedUserActivities.add(newUserActivity);
    }
    try {
      await Provider.of<RoomsProvider>(context, listen: false)
          .addActivitiesToRoomie(
              selectedUserActivities, widget.userId, activitesPointsSum);

      var username = await Provider.of<RoomsProvider>(context, listen: false)
          .getUsernameFromId(widget.userId);

      Navigator.of(context).pushReplacementNamed(
          GratificationActivityScreen.routeName,
          arguments: {'points': activitesPointsSum, 'username': username});
    } catch (err) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error occured'),
          content: const Text('Sth went wrong'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Okay'),
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

  void _deleteActivity(BuildContext context, String id) async {
    try {
      await Provider.of<ActivitiesProvider>(context, listen: false)
          .deleteActivity(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Activity deleted!',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Deleting failed!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    activitiesLength = widget.activities.length;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (activitiesLength < widget.activities.length) {
      activitiesLength = widget.activities.length;
      selectedIndexes.add(widget.activities.length - 1);
      activitesPointsSum +=
          widget.activities[widget.activities.length - 1].points;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 32,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              child: AnimatedSwitcher(
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                duration: const Duration(milliseconds: 600),
                child: Text(
                  '$activitesPointsSum',
                  key: ValueKey<int>(activitesPointsSum),
                ),
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
                  itemBuilder: ((context, index) => Slidable(
                        key: ValueKey(index),
                        endActionPane: ActionPane(
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                Navigator.of(context).pushNamed(
                                    EditActivityScreen.routeName,
                                    arguments: {
                                      'id': widget.activities[index].id,
                                    }).then((value) {
                                  activitesPointsSum = 0;
                                  selectedIndexes = [];
                                });
                              },
                              backgroundColor:
                                  const Color.fromRGBO(47, 149, 153, 0.7),
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              borderRadius: BorderRadius.circular(30),
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (context) => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Are you sure?'),
                                  content: const Text(
                                      'Do you want to remove this activity?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('NO')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            var howManyItems = selectedIndexes
                                                .where((ind) => ind == index)
                                                .length;

                                            if (howManyItems > 0) {
                                              selectedIndexes.removeWhere(
                                                  (ind) => ind == index);
                                              activitesPointsSum -= widget
                                                      .activities[index]
                                                      .points *
                                                  howManyItems;
                                            }
                                          });
                                          _deleteActivity(context,
                                              widget.activities[index].id);
                                        },
                                        child: const Text('YES')),
                                  ],
                                ),
                              ),
                              backgroundColor:
                                  const Color.fromRGBO(236, 32, 73, 1),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              borderRadius: BorderRadius.circular(30),
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Card(
                          color: selectedIndexes.contains(index)
                              ? const Color.fromRGBO(195, 227, 227, 1)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 20,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: CheckboxListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              title: Text(
                                widget.activities[index].activityName,
                                style: TextStyle(
                                    fontWeight: selectedIndexes.contains(index)
                                        ? FontWeight.w500
                                        : FontWeight.normal),
                              ),
                              secondary: CircleAvatar(
                                radius:
                                    selectedIndexes.contains(index) ? 23 : 22,
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
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                              tileColor: selectedIndexes.contains(index)
                                  ? const Color.fromRGBO(195, 227, 227, 1)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      )),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: selectedIndexes.isEmpty ? null : () => _saveActivites(),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.grey;
                  }
                  return Theme.of(context).colorScheme.primary;
                },
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Save'),
          )
        ],
      ),
    );
  }
}
