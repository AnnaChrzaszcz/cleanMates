import 'package:clean_mates_app/models/room.dart';
import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activities_provider.dart';
import '../providers/rooms_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
        // actions: [
        //   IconButton(
        //       onPressed: () => _goToEditActivity(context, myRoom),
        //       icon: Icon(Icons.add))
        // ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => _goToEditActivity(context, myRoom),
        child: Icon(Icons.add),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshActivities(context, myRoom.id),
        builder: ((context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<ActivitiesProvider>(
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
                                          onPressed: () => _deleteActivity(
                                              context,
                                              activitiesData
                                                  .activities[index].id),
                                        ),
                                      ],
                                    ),
                                    leading: CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            Theme.of(context).dividerColor,
                                        foregroundColor: Colors.white,
                                        child: FittedBox(
                                          child: Text(
                                              '${activitiesData.activities[index].points}'),
                                        )),
                                    title: Text(
                                      activitiesData
                                          .activities[index].activityName,
                                      style: TextStyle(),
                                    ),
                                    subtitle: Text(myRoom.roomName),
                                  ),
                                  Divider()
                                ],
                              )),
                        ),
                      )),
              )),
      ),
    );
  }
}
