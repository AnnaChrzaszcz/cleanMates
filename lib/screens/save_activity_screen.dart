import 'package:clean_mates_app/models/room.dart';
import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/widgets/activity/save_activity_container.dart';
import 'package:clean_mates_app/widgets/fab/custom_add_fab.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import '../providers/activities_provider.dart';
import '../providers/rooms_provider.dart';

class SaveActivityScreen extends StatelessWidget {
  static const routeName = '/saveActivity';

  Future<void> _refreshActivities(BuildContext context, String roomId) async {
    await Provider.of<ActivitiesProvider>(context, listen: false)
        .fetchAndSetData(roomId);
  }

  void _deleteActivity(BuildContext context, String id) async {
    try {
      await Provider.of<ActivitiesProvider>(context, listen: false)
          .deleteActivity(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Activity deleted!',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deleting failed!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var myRoom = Provider.of<RoomsProvider>(context).myRoom;
    final userId = ModalRoute.of(context).settings.arguments as String;
    return FutureBuilder(
      future: _refreshActivities(context, myRoom.id),
      builder: ((context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? Scaffold(
              appBar: AppBar(title: const Text('Save activity')),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Consumer<ActivitiesProvider>(
              builder: ((ctx, activitiesData, _) => Scaffold(
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endFloat,
                  floatingActionButton:
                      CustomAddFab(activityScreen: true, roomId: myRoom.id),
                  appBar: AppBar(
                    title: Text('Save activity'),
                  ),
                  body: CustomRefreshIndicator(
                    builder: MaterialIndicatorDelegate(
                      builder: (context, controller) {
                        return const CircleAvatar(
                          radius: 60,
                          backgroundColor: Color.fromRGBO(47, 149, 153, 1),
                          child: RiveAnimation.asset(
                            'assets/animations/indicator.riv',
                          ),
                        );
                      },
                    ),
                    onRefresh: () => _refreshActivities(context, myRoom.id),
                    child:
                        saveActivity(myRoom, context, activitiesData, userId),
                  ))),
            )),
    );
  }

  Widget saveActivity(Room myRoom, BuildContext context,
      ActivitiesProvider activitiesData, String userId) {
    return myRoom.roomies.length == 1
        ? Center(
            child: Text(
              'You need to add a roomie to your room',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          )
        : activitiesData.activities.isEmpty
            ? Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                margin:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You need at least one activity in your activities overview',
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                            EditActivityScreen.routeName,
                            arguments: {'roomId': myRoom.id}),
                        child: Text(
                          'Click the "+" below to add new activity',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ))
                  ],
                ),
              )
            : SaveActivityContainer(activitiesData.activities, userId,
                () => _refreshActivities(context, myRoom.id));
  }
}
