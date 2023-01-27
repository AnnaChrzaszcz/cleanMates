import 'package:clean_mates_app/models/userActivity.dart';
import 'package:clean_mates_app/screens/user_dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/activity.dart';
import '../../providers/rooms_provider.dart';
import 'package:provider/provider.dart';

class SaveActivityContainer extends StatefulWidget {
  final List<Activity> activities;
  final String userId;
  SaveActivityContainer(@required this.activities, @required this.userId);

  @override
  _SaveActivityContainerState createState() => _SaveActivityContainerState();
}

class _SaveActivityContainerState extends State<SaveActivityContainer> {
  var selectedIndexes = [];
  var activitesPointsSum = 0;
  var _isLoading = false;
  final user = FirebaseAuth.instance.currentUser;

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${widget.userId == user.uid ? 'You earned ${activitesPointsSum} points' : '${activitesPointsSum} points earned'}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (err) {
      print(err);
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
      Navigator.of(context).pushReplacementNamed(UserDashboardScreen.routeName);
      //Navigator.of(context).pop(); //JAK POCZEKAC ZEBY SNACK BAR ZNIKNAL?
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text(
                '${activitesPointsSum}',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: ListView.builder(
                itemCount: widget.activities.length,
                itemBuilder: ((context, index) => Column(
                      children: [
                        CheckboxListTile(
                          title: Text(
                            widget.activities[index].activityName,
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          secondary: CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            child: CircleAvatar(
                              radius: 20,
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              child: Text(
                                '${widget.activities[index].points}',
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
                        ),
                        Divider()
                      ],
                    )),
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
