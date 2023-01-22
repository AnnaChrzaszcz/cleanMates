import 'dart:math' as Math;
import 'package:clean_mates_app/models/room.dart';
import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:clean_mates_app/widgets/fab/custom_add_fab.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import '../providers/activities_provider.dart';
import '../providers/rooms_provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class ActivitiesScreen extends StatelessWidget {
  static const routeName = '/activities';

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

  void _goToEditActivity(BuildContext context, Room myRoom) {
    Navigator.of(context).pushNamed(EditActivityScreen.routeName,
        arguments: {'roomId': myRoom.id});
  }

  @override
  Widget build(BuildContext context) {
    Room myRoom = Provider.of<RoomsProvider>(context).myRoom;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Activities overview'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          CustomAddFab(activityScreen: true, roomId: myRoom.id),
      body: FutureBuilder(
        future: _refreshActivities(context, myRoom.id),
        builder: ((context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : CustomRefreshIndicator(
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
                child: Consumer<ActivitiesProvider>(
                  builder: ((ctx, activitiesData, _) => activitiesData
                          .activities.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(8.0),
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'You have no activities yet',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                'Define some activities below (+)',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              RotatedBox(
                                  quarterTurns: 2,
                                  child: Container(
                                    width: double.infinity * 1 / 3,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 40, horizontal: 10),
                                    child: Lottie.asset(
                                      'assets/animations/lottie/box.json',
                                      fit: BoxFit.contain,
                                    ),
                                  )),
                            ],
                          ),
                        )
                      : Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: ListView.builder(
                            itemCount: activitiesData.activities.length,
                            itemBuilder: ((context, index) => Column(
                                  children: [
                                    ListTile(
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  EditActivityScreen.routeName,
                                                  arguments: {
                                                    'id': activitiesData
                                                        .activities[index].id,
                                                  });
                                            },
                                          ),
                                          IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title:
                                                        Text('Are you sure?'),
                                                    content: Text(
                                                        'Do you want to remove this activity?'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(ctx)
                                                                .pop();
                                                          },
                                                          child: Text('NO')),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(ctx)
                                                                .pop();
                                                            _deleteActivity(
                                                                context,
                                                                activitiesData
                                                                    .activities[
                                                                        index]
                                                                    .id);
                                                          },
                                                          child: Text('YES')),
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                      leading: CircleAvatar(
                                          radius: 25,
                                          backgroundColor:
                                              Theme.of(context).dividerColor,
                                          foregroundColor: Colors.white,
                                          child: FittedBox(
                                              child: Text(
                                                  '${activitiesData.activities[index].points}'))),
                                      title: Text(
                                        activitiesData
                                            .activities[index].activityName,
                                        style: TextStyle(),
                                      ),
                                    ),
                                    Divider()
                                  ],
                                )),
                          ),
                        )),
                ),
              )),
      ),
    );
  }
}
