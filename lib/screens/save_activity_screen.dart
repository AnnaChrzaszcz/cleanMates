import 'package:clean_mates_app/screens/activities_screen.dart';
import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/widgets/activity/save_activity_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activities_provider.dart';
import '../providers/rooms_provider.dart';

class SaveActivityScreen extends StatelessWidget {
  static const routeName = '/saveActivity';

  Future<void> _refreshActivities(BuildContext context, String roomId) async {
    await Provider.of<ActivitiesProvider>(context, listen: false)
        .fetchAndSetData(roomId);
  }

  @override
  Widget build(BuildContext context) {
    var myRoom = Provider.of<RoomsProvider>(context).myRoom;
    final userId = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Save activity'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditActivityScreen.routeName,
                    arguments: {'roomId': myRoom.id});
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: _refreshActivities(context, myRoom.id),
        builder: ((context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<ActivitiesProvider>(
                builder: ((ctx, activitiesData, _) => activitiesData
                            .activities.length ==
                        0
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                        margin:
                            EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'You need at least one activity in your dictionary',
                              style: Theme.of(context).textTheme.headline6,
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pushReplacementNamed(
                                        ActivitiesScreen.routeName),
                                child: Text('Go to dictionary'))
                          ],
                        ),
                      )
                    : SaveActivityContainer(activitiesData.activities, userId)),
              )),
      ),
    );
  }
}
