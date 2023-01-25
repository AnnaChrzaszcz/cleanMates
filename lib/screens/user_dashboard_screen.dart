import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clean_mates_app/screens/buy_gift_screen.dart';
import 'package:clean_mates_app/screens/history_screen.dart';
import 'package:clean_mates_app/screens/intro_screen.dart';
import 'package:clean_mates_app/screens/onboarding_screen.dart';
import 'package:clean_mates_app/screens/stats_screen.dart';
import 'package:clean_mates_app/widgets/fab/action_button.dart';
import 'package:clean_mates_app/widgets/fab/expandable_fab.dart';
import 'package:clean_mates_app/widgets/room/join_room.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:rive/rive.dart';

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
import 'package:shimmer/shimmer.dart';

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
        'color': Color.fromRGBO(236, 32, 73, 0.7),
      },
      {
        'title': 'Money balance',
        'routeName': 'a', //ExchangeToPrize.routeName,
        'imagePath': 'assets/images/money.png',
        'color': Color.fromRGBO(167, 34, 110, 0.7),
      },
      {
        'title': 'Buy gift',
        'routeName': BuyGiftScreen.routeName,
        'imagePath': 'assets/images/myPrize.png',
        'color': Color.fromRGBO(247, 219, 79, 0.7),
      },
      {
        'title': 'Stats',
        'routeName': StatsScreen.routeName, //StatsScreen.routeName,
        'imagePath': 'assets/images/stats.png',
        'color': Color.fromRGBO(242, 107, 56, 0.7),
      },
    ];

    return FutureBuilder(
      future: _myFuture,
      builder: (context, snapshot) {
        print(snapshot);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Consumer<RoomsProvider>(
            builder: ((context, roomsdata, _) {
              if (roomsdata.myRoom != null) {
                print(roomsdata.myRoom.roomName);
                roomie = roomsdata.myRoom.roomies
                    .firstWhere((roomie) => roomie.id == user.uid);
                return Scaffold(
                    appBar: AppBar(
                      title: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText(user.displayName),
                          ],
                          isRepeatingAnimation: false,
                        ),
                      ),
                    ),
                    floatingActionButton: ExpandableFab(
                      distance: 76.0,
                      children: [
                        ActionButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(UserRoomScreen.routeName)
                                .then((_) {});
                          },
                          icon: const Icon(Icons.home),
                        ),
                        ActionButton(
                          onPressed: () => {
                            Navigator.of(context)
                                .pushNamed(HistoryScreen.routeName)
                                .then((_) {})
                          },
                          icon: const Icon(Icons.history),
                        ),
                      ],
                    ),
                    drawer: AppDrawer(),
                    body: userDashboardContainer(
                      roomie.points,
                      actions,
                      roomsdata.myRoom,
                      roomie.id,
                    ));
              } else {
                return Scaffold(
                    appBar: AppBar(
                      actions: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: IconButton(
                            icon: Icon(Icons.question_mark),
                            onPressed: () =>
                                Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      IntroScreen(
                                isLogin: true,
                              ),
                            )),
                          ),
                        ),
                      ],
                      //title: Text(roomie.userName ?? ''),
                      title: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText(user.displayName),
                          ],
                          isRepeatingAnimation: false,
                        ),
                      ),
                    ),
                    drawer: AppDrawer(),
                    body: UserHasNoRoom(_joinToRoom, _createdRoom));
              }
            }),
          );
        }
        return Scaffold(body: Container(child: Text('')));
      },
    );
  }

  Widget userDashboardContainer(
      points, List<Map<String, Object>> actions, Room room, String userId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      margin: EdgeInsets.all(8),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              flex: 2,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Shimmer.fromColors(
                    baseColor: Theme.of(context).primaryColor,
                    highlightColor: Color.fromRGBO(167, 34, 110, 0.4),
                    //highlightColor: Colors.white,
                    child: CircleAvatar(
                      radius: 110,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  CircleAvatar(
                    radius: 104,
                    backgroundColor: Colors.white,
                  ),
                  CircleAvatar(
                    radius: 98,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  CircleAvatar(
                    radius: 92,
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
              )),
          Expanded(
            flex: 3,
            child: CustomRefreshIndicator(
              builder: MaterialIndicatorDelegate(
                builder: (context, controller) {
                  return const CircleAvatar(
                    radius: 55,
                    backgroundColor: Color.fromRGBO(47, 149, 153, 1),
                    child: RiveAnimation.asset(
                      'assets/animations/indicator.riv',
                    ),
                  );
                },
              ),
              onRefresh: _refreshRoom,
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
          ),
        ],
      ),
    );
  }
}
