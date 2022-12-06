import 'package:clean_mates_app/widgets/save_activity_container.dart';
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
      appBar: AppBar(title: Text('Save activity')),
      body: FutureBuilder(
        future: _refreshActivities(context, myRoom.id),
        builder: ((context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<ActivitiesProvider>(
                builder: ((ctx, activitiesData, _) =>
                    SaveActivityContainer(activitiesData.activities, userId)),
              )),
      ),
    );
  }
}
