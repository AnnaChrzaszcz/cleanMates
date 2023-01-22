import 'package:clean_mates_app/models/room.dart';
import 'package:clean_mates_app/models/roomie.dart';
import 'package:clean_mates_app/models/userActivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';
import 'package:provider/provider.dart';
import '../providers/rooms_provider.dart';

class StatsScreen extends StatefulWidget {
  //tutaj zrobione responsive
  static const routeName = '/stats';

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  var dateSelected = DateTime.now();
  List<UserActivity> roomActivities = [];
  var userId;
  var roomieId;
  Roomie you;
  Roomie roomie;
  Room myRoom;
  var yourDailySum;
  var roomieDailySum;

  void _dateChanged(DateTime val) {
    yourDailySum = 0;
    roomieDailySum = 0;
    setState(() {
      dateSelected = val;
      roomActivities = Provider.of<RoomsProvider>(context, listen: false)
          .getRoomActivitiesByDate(val);
      roomActivities.forEach((act) {
        if (act.roomieId == userId) {
          yourDailySum += act.points;
        } else if (act.roomieId == roomieId) {
          roomieDailySum += act.points;
        }
      });
    });
  }

  @override
  void initState() {
    yourDailySum = 0;
    roomieDailySum = 0;
    myRoom = Provider.of<RoomsProvider>(context, listen: false).myRoom;
    roomActivities = Provider.of<RoomsProvider>(context, listen: false)
        .getRoomActivitiesByDate(dateSelected);

    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
    you = myRoom.roomies.firstWhere((roomie) => roomie.id == userId);
    if (myRoom.roomies.length > 1) {
      roomie = myRoom.roomies.firstWhere((roomie) => roomie.id != userId);
      roomieId = roomie.id;
    }
    roomActivities.forEach((act) {
      print(act.activityName);
      if (act.roomieId == userId) {
        yourDailySum += act.points;
      } else if (act.roomieId == roomieId) {
        roomieDailySum += act.points;
      }
    });
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
      appBar: AppBar(title: Text('Stats')),
      body: myRoom.roomies.length == 1
          ? Center(
              child: Text(
                'You need to add a roomie to your room',
                style: Theme.of(context).textTheme.headline6,
              ),
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => _showIOS_DatePicker(context),
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.date_range,
                                size: 28,
                              ),
                              SizedBox(
                                width: 5,
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
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (roomActivities.isNotEmpty)
                    Expanded(
                      flex: 15,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Timeline.tileBuilder(
                          theme: TimelineThemeData(
                            color: const Color.fromRGBO(242, 107, 56,
                                1), //Theme.of(context).dividerColor
                            connectorTheme: ConnectorThemeData(
                              color: Color.fromRGBO(242, 107, 56, 1),
                            ),
                          ),
                          builder: TimelineTileBuilder.fromStyle(
                            contentsAlign: ContentsAlign.basic,
                            indicatorStyle: IndicatorStyle.outlined,
                            oppositeContentsBuilder: (context, index) =>
                                Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: index == 0
                                  ? Column(
                                      children: you != null
                                          ? [
                                              Text(
                                                '${you.userName}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              Text('sum: ${yourDailySum} pts',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16))
                                            ]
                                          : [
                                              Text('you'),
                                            ],
                                    )
                                  : roomActivities[index - 1].roomieId == userId
                                      ? Text(
                                          '${DateFormat('HH:mm').format(roomActivities[index - 1].creationDate)}  ${roomActivities[index - 1].activityName} (${roomActivities[index - 1].points}p) ',
                                          textAlign: TextAlign.end,
                                        )
                                      : Text(''),
                            ),
                            contentsBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: index == 0
                                  ? Column(
                                      children: you != null
                                          ? [
                                              Text(
                                                '${roomie.userName}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              Text('sum: ${roomieDailySum} pts',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16))
                                            ]
                                          : [
                                              Text('roomie'),
                                            ],
                                    )
                                  : roomActivities[index - 1].roomieId ==
                                          roomieId
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
                      flex: 15,
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
