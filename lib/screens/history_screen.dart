import 'package:clean_mates_app/models/roomie.dart';
import 'package:clean_mates_app/models/userActivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';
import 'package:provider/provider.dart';
import '../providers/rooms_provider.dart';

class HistoryScreen extends StatefulWidget {
  //tutaj zrobione responsive
  static const routeName = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  var dateSelected = DateTime.now();
  List<UserActivity> roomActivities = [];
  var userId;
  var roomieId;
  Roomie you;
  Roomie roomie;

  void _dateChanged(DateTime val) {
    setState(() {
      dateSelected = val;
      roomActivities = Provider.of<RoomsProvider>(context, listen: false)
          .getRoomActivitiesByDate(val);
    });
  }

  @override
  void initState() {
    var myRoom = Provider.of<RoomsProvider>(context, listen: false).myRoom;
    roomActivities = Provider.of<RoomsProvider>(context, listen: false)
        .getRoomActivitiesByDate(dateSelected);
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
    you = myRoom.roomies.firstWhere((roomie) => roomie.id == userId);
    roomie = myRoom.roomies.firstWhere((roomie) => roomie.id != userId);
    roomieId = roomie.id;
  }

  void _showIOS_DatePicker(ctx) {
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              height: 190,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                children: [
                  Container(
                    height: 180,
                    child: CupertinoDatePicker(
                        initialDateTime: dateSelected,
                        onDateTimeChanged: (val) => _dateChanged(val)),
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(8),
                elevation: 8,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.date_range),
                        iconSize: 28,
                        onPressed: () => _showIOS_DatePicker(context),
                      ),
                      Text(
                        DateFormat('dd/MM').format(dateSelected),
                        style: TextStyle(fontSize: 19),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (roomActivities.isNotEmpty)
              Expanded(
                flex: 10,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Timeline.tileBuilder(
                    theme: TimelineThemeData(
                      color: const Color.fromRGBO(
                          242, 107, 56, 1), //Theme.of(context).dividerColor
                      connectorTheme: ConnectorThemeData(
                        color: Color.fromRGBO(242, 107, 56, 1),
                      ),
                    ),
                    builder: TimelineTileBuilder.fromStyle(
                      contentsAlign: ContentsAlign.basic,
                      indicatorStyle: IndicatorStyle.outlined,
                      oppositeContentsBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: index == 0
                            ? Text(
                                you != null ? you.userName : "you",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )
                            : roomActivities[index - 1].roomieId == userId
                                ? Text(
                                    '${DateFormat('HH:mm').format(roomActivities[index - 1].creationDate)}  ${roomActivities[index - 1].activityName}')
                                : Text(''),
                      ),
                      contentsBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: index == 0
                            ? Text(
                                roomie != null ? roomie.userName : "roomie",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              )
                            : roomActivities[index - 1].roomieId == roomieId
                                ? Text(
                                    '${DateFormat('HH:mm').format(roomActivities[index - 1].creationDate)}  ${roomActivities[index - 1].activityName}')
                                : Text(''),
                      ),
                      itemCount: roomActivities.length + 1,
                    ),
                  ),
                ),
              ),
            if (roomActivities.length == 0)
              const Expanded(
                flex: 9,
                child: Center(
                  child: Text('No activities during selected day'),
                ),
              )
          ],
        ),
      ),
    );
  }
}
