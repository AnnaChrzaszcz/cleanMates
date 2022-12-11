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

  void _saveActivites() async {
    setState(() {
      _isLoading = true;
    });
    List<Activity> selectedActivities = [];
    selectedIndexes.forEach((index) {
      selectedActivities.add(widget.activities[index]);
    });
    try {
      await Provider.of<RoomsProvider>(context, listen: false)
          .addActivitiesToRoomie(selectedActivities, widget.userId,
              widget.activities[0].roomId, activitesPointsSum);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You earned ${activitesPointsSum} points'),
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
      Navigator.of(context).pop(); //JAK POCZEKAC ZEBY SNACK BAR ZNIKNAL?
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: Text(
            '${activitesPointsSum}',
            style: TextStyle(fontSize: 15),
          ),
        ),
        Container(
          height: 600,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          //decoration: BoxDecoration(border: Border.all(color: Colors.pink)),
          child: ListView.builder(
            itemCount: widget.activities.length,
            itemBuilder: ((context, index) => Column(
                  children: [
                    CheckboxListTile(
                      title: Text(
                        widget.activities[index].activityName,
                        style: TextStyle(),
                      ),
                      secondary: CircleAvatar(
                        radius: 20,
                        backgroundColor: selectedIndexes.contains(index)
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        foregroundColor: Colors.white,
                        child: Text('${widget.activities[index].points}'),
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
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    Divider()
                  ],
                )),
          ),
        ),
        ElevatedButton(
          onPressed:
              selectedIndexes.length <= 0 ? null : () => _saveActivites(),
          child: _isLoading ? CircularProgressIndicator() : Text('Save'),
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
