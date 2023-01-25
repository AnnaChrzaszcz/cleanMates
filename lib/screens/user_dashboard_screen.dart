import 'dart:math';

import 'package:clean_mates_app/screens/buy_gift_screen.dart';
import 'package:clean_mates_app/screens/history_screen.dart';
import 'package:clean_mates_app/screens/stats_screen.dart';

import '../screens/save_activity_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/room/user_has_no_room.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/action_item.dart';
import '../models/room.dart';
import '../screens/user_room_screen.dart';
import '../providers/rooms_provider.dart';
import 'package:provider/provider.dart';
import '../models/roomie.dart';

class UserDashboardScreen extends StatefulWidget {
  static const String routeName = '/userDashboard';

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  Roomie roomie;
  User user;
  var routeArgs;
  Future<Room> _myFuture;
  AppBar appBar = AppBar(
    title: Text('test'),
  );

  var _isInit = true;
  void _joinToRoom(Room selectedRoom) {
    Provider.of<RoomsProvider>(context, listen: false)
        .joinToRoom(selectedRoom.id)
        .then((_) {});
  }

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    _myFuture = _refreshRoom();
    super.initState();
  }

  void _createdRoom() {}

  Future<Room> _refreshRoom() async {
    await Provider.of<RoomsProvider>(context, listen: false)
        .getUserRoom(user.uid);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      roomie = Roomie(
          id: user.uid,
          userName: user.displayName,
          points: null,
          imageUrl: user.photoURL);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Save Activity',
        'routeName': SaveActivityScreen.routeName,
        'imagePath': 'assets/images/cleaning.png',
        'color': Color.fromRGBO(236, 32, 73, 1),
      },
      {
        'title': 'Money balance',
        'routeName': '', //ExchangeToPrize.routeName,
        'imagePath': 'assets/images/money.png',
        'color': Color.fromRGBO(167, 34, 110, 1),
      },
      {
        'title': 'Buy gift',
        'routeName': BuyGiftScreen.routeName,
        'imagePath': 'assets/images/myPrize.png',
        'color': Color.fromRGBO(247, 219, 79, 1),
      },
      {
        'title': 'Stats',
        'routeName': StatsScreen.routeName, //StatsScreen.routeName,
        'imagePath': 'assets/images/stats.png',
        'color': Color.fromRGBO(242, 107, 56, 1),
      },
    ];

    return Scaffold(
      //PRZY PIERWSZYM LOGOWANIU COS NIE DZIALA
      appBar: AppBar(
        //title: Text(name),
        title: Text(user.displayName),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _myFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<RoomsProvider>(
              builder: ((context, roomsdata, _) {
                if (roomsdata.myRoom != null) {
                  roomie = roomsdata.myRoom.roomies
                      .firstWhere((roomie) => roomie.id == user.uid);
                  return userDashboardContainer(
                    roomie.points,
                    actions,
                    roomsdata.myRoom,
                    roomie.id,
                  );
                } else {
                  return UserHasNoRoom(_joinToRoom, _createdRoom);
                }
              }),
            );
          }
          return Container(child: Text(''));
        },
      ),
    );
  }

  Widget userDashboardContainer(
      points, List<Map<String, Object>> actions, Room room, String userId) {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: Colors.white,
      onRefresh: _refreshRoom,
      child: Container(
        height:
            MediaQuery.of(context).size.height - appBar.preferredSize.height,
        padding: EdgeInsets.all(8),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height -
                appBar.preferredSize.height,
            width: double.infinity,
            child: Column(children: [
              Expanded(
                flex: 4,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    CircleAvatar(
                      radius: 94,
                      backgroundColor: Colors.white,
                    ),
                    CircleAvatar(
                      radius: 88,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    CircleAvatar(
                      radius: 82,
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: FittedBox(
                          child: Column(
                            children: [
                              Text(
                                '${points.toString()}',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'POINTS',
                                style:
                                    TextStyle(fontSize: 20, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded(
              //   flex: 1,
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       IconButton(
              //         onPressed: () {
              //           Navigator.of(context)
              //               .pushNamed(UserRoomScreen.routeName)
              //               .then((_) {});
              //         },
              //         icon: const Icon(Icons.home),
              //         iconSize: 40,
              //       ),
              //       IconButton(
              //         onPressed: () {
              //           Navigator.of(context)
              //               .pushNamed(HistoryScreen.routeName)
              //               .then((_) {});
              //         },
              //         icon: const Icon(Icons.history),
              //         iconSize: 40,
              //       ),
              //     ],
              //   ),
              // ),
              Expanded(
                flex: 7,
                child: GridView(
                  padding: const EdgeInsets.all(10),
                  children: actions
                      .map(
                        (action) => ActionItem(
                            action['title'] as String,
                            action['routeName'] as String,
                            action['imagePath'] as String,
                            userId,
                            action['color'] as Color),
                      )
                      .toList(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
