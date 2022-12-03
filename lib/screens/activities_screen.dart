import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activities_provider.dart';

class ActivitiesScreen extends StatelessWidget {
  static const routeName = '/activities';

  Future<void> _refreshActivities(BuildContext context) async {
    await Provider.of<ActivitiesProvider>(context, listen: false)
        .fetchAndSetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditActivityScreen.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshActivities(context),
        builder: ((context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<ActivitiesProvider>(
                builder: ((ctx, activitiesData, _) => Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: ListView.builder(
                        itemCount: activitiesData.activities.length,
                        itemBuilder: ((context, index) => Column(
                              children: [
                                ListTile(
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          EditActivityScreen.routeName,
                                          arguments: activitiesData
                                              .activities[index].id);
                                    },
                                  ),
                                  leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor:
                                          Theme.of(context).dividerColor,
                                      foregroundColor: Colors.white,
                                      child: Text(
                                          '${activitiesData.activities[index].points}')),
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
              )),
      ),
    );
  }
}
