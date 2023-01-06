import 'dart:async';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_picker_timeline/flutter_date_picker_timeline.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:timelines/timelines.dart';

import 'package:clean_mates_app/models/room.dart';
import 'package:clean_mates_app/models/roomie.dart';
import 'package:clean_mates_app/models/userActivity.dart';

import '../providers/rooms_provider.dart';

class HistoryScreen extends StatefulWidget {
  //tutaj zrobione responsive
  static const routeName = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  ValueNotifier<DateTime> timelineDate;
  ValueNotifier<List<UserActivity>> roomActivitiesNotifier;
  var userId;
  var roomieId;
  Roomie you;
  Roomie roomie;
  Room myRoom;

  Future<void> _refreshData() async {
    Provider.of<RoomsProvider>(context, listen: false)
        .getUserRoom(userId)
        .then((room) {
      roomActivitiesNotifier.value =
          Provider.of<RoomsProvider>(context, listen: false)
              .getRoomActivitiesByDate(timelineDate.value);
    });
  }

  @override
  void initState() {
    myRoom = Provider.of<RoomsProvider>(context, listen: false).myRoom;
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
    you = myRoom.roomies.firstWhere((roomie) => roomie.id == userId);
    if (myRoom.roomies.length > 1) {
      roomie = myRoom.roomies.firstWhere((roomie) => roomie.id != userId);
      roomieId = roomie.id;
    }
    timelineDate = ValueNotifier<DateTime>(DateTime.now());
    roomActivitiesNotifier = ValueNotifier<List<UserActivity>>(
        Provider.of<RoomsProvider>(context, listen: false)
            .getRoomActivitiesByDate(timelineDate.value));
    print(roomActivitiesNotifier.value.length);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timelineDate.dispose();
    roomActivitiesNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
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
                  FlutterDatePickerTimeline(
                    startDate: DateTime.now().subtract(const Duration(days: 7)),
                    selectedItemWidth: 140,
                    endDate: DateTime.now(),
                    itemHeight: 60.0,
                    selectedItemBackgroundColor:
                        Theme.of(context).iconTheme.color,
                    initialSelectedDate: timelineDate.value,
                    onSelectedDateChange: (DateTime dateTime) {
                      timelineDate.value = dateTime;
                      roomActivitiesNotifier.value =
                          Provider.of<RoomsProvider>(context, listen: false)
                              .getRoomActivitiesByDate(dateTime);
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ValueListenableBuilder(
                    valueListenable: roomActivitiesNotifier,
                    builder: (context, value, child) {
                      return Expanded(
                        flex:
                            MediaQuery.of(context).size.height < 680.0 ? 2 : 3,
                        child: roomActivitiesNotifier.value.isNotEmpty
                            ? CustomRefreshIndicator(
                                builder: MaterialIndicatorDelegate(
                                  builder: (context, controller) {
                                    return const CircleAvatar(
                                      radius: 55,
                                      backgroundColor:
                                          Color.fromRGBO(47, 149, 153, 1),
                                      child: RiveAnimation.asset(
                                        'assets/animations/indicator.riv',
                                      ),
                                    );
                                  },
                                ),
                                onRefresh: () => _refreshData(),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Timeline.tileBuilder(
                                    theme: TimelineThemeData(
                                      color: const Color.fromRGBO(242, 107, 56,
                                          1), //Theme.of(context).dividerColor
                                      connectorTheme: const ConnectorThemeData(
                                        color: Color.fromRGBO(242, 107, 56, 1),
                                      ),
                                    ),
                                    builder: TimelineTileBuilder.fromStyle(
                                      contentsAlign: ContentsAlign.basic,
                                      indicatorStyle: IndicatorStyle.outlined,
                                      oppositeContentsBuilder:
                                          (context, index) => Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: index == 0
                                            ? Text(
                                                you != null
                                                    ? you.userName
                                                    : "you",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              )
                                            : roomActivitiesNotifier
                                                        .value[index - 1]
                                                        .roomieId ==
                                                    userId
                                                ? Text(
                                                    '${DateFormat('HH:mm').format(roomActivitiesNotifier.value[index - 1].creationDate)}  ${roomActivitiesNotifier.value[index - 1].activityName}',
                                                    textAlign: TextAlign.end,
                                                  )
                                                : const Text(''),
                                      ),
                                      contentsBuilder: (context, index) =>
                                          Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: index == 0
                                            ? Text(
                                                roomie != null
                                                    ? roomie.userName
                                                    : "roomie",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              )
                                            : roomActivitiesNotifier
                                                        .value[index - 1]
                                                        .roomieId ==
                                                    roomieId
                                                ? Text(
                                                    '${DateFormat('HH:mm').format(roomActivitiesNotifier.value[index - 1].creationDate)}  ${roomActivitiesNotifier.value[index - 1].activityName}')
                                                : const Text(''),
                                      ),
                                      itemCount:
                                          roomActivitiesNotifier.value.length +
                                              1,
                                    ),
                                  ),
                                ),
                              )
                            : CustomRefreshIndicator(
                                builder: MaterialIndicatorDelegate(
                                  builder: (context, controller) {
                                    return const CircleAvatar(
                                      radius: 55,
                                      backgroundColor:
                                          Color.fromRGBO(47, 149, 153, 1),
                                      child: RiveAnimation.asset(
                                        'assets/animations/indicator.riv',
                                      ),
                                    );
                                  },
                                ),
                                onRefresh: () => _refreshData(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30, horizontal: 8),
                                  child: ListView(children: const [
                                    Text(
                                      'No activities during selected day',
                                      textAlign: TextAlign.center,
                                    ),
                                  ]),
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
