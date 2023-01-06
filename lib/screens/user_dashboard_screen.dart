import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clean_mates_app/screens/buy_gift_screen.dart';
import 'package:clean_mates_app/screens/history_screen.dart';
import 'package:clean_mates_app/widgets/fab/action_button.dart';
import 'package:clean_mates_app/widgets/fab/expandable_fab.dart';
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

class UserDashboardScreen extends StatefulWidget {
  static const String routeName = '/userDashboard';

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  Roomie roomie;
  final user = FirebaseAuth.instance.currentUser;
  var routeArgs;
  var isRoomie = false;

  var _isInit = true;
  void _joinToRoom(Room selectedRoom) {
    Provider.of<RoomsProvider>(context, listen: false)
        .joinToRoom(selectedRoom.id)
        .then((_) {});
  }

  void _createdRoom() {}

  Future<void> _refreshRoom() async {
    await Provider.of<RoomsProvider>(context, listen: false)
        .getUserRoom(roomie.id);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      if (routeArgs != null) {
        final userId = routeArgs['userId'];
        final name = routeArgs['name'];
        final imageUrl = routeArgs['imageUrl'];
        final points = routeArgs['points'];

        roomie = Roomie(
            id: userId, userName: name, points: points, imageUrl: imageUrl);
        if (userId != user.uid) {
          isRoomie = true;
        }
      } else {
        isRoomie = false;
        roomie = Roomie(
            id: user.uid,
            userName: user.displayName,
            points: null,
            imageUrl: user.photoURL);
        // }
      }
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
        'color': Color.fromRGBO(236, 32, 73, 0.5),
      },
      {
        'title': 'Money balance',
        'routeName': '', //ExchangeToPrize.routeName,
        'imagePath': 'assets/images/money.png',
        'color': Color.fromRGBO(167, 34, 110, 0.5),
      },
      {
        'title': 'Buy gift',
        'routeName': BuyGiftScreen.routeName,
        'imagePath': 'assets/images/myPrize.png',
        'color': Color.fromRGBO(247, 219, 79, 0.5),
      },
      {
        'title': 'Stats',
        'routeName': '', //StatsScreen.routeName,
        'imagePath': 'assets/images/stats.png',
        'color': Color.fromRGBO(242, 107, 56, 0.5),
      },
    ];

    return Scaffold(
      //PRZY PIERWSZYM LOGOWANIU COS NIE DZIALA
      appBar: AppBar(
        //title: Text(roomie.userName ?? ''),
        title: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 20.0,
          ),
          child: AnimatedTextKit(
            animatedTexts: [
              WavyAnimatedText(roomie.userName ?? ''),
            ],
            isRepeatingAnimation: false,
          ),
        ),
      ),
      drawer: AppDrawer(),
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
      body: FutureBuilder(
        future: _refreshRoom(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<RoomsProvider>(
              builder: ((context, roomsdata, _) {
                if (roomsdata.myRoom != null) {
                  if (!isRoomie) {
                    roomie = roomsdata.myRoom.roomies
                        .firstWhere((roomie) => roomie.id == user.uid);
                  } else {
                    roomie = roomsdata.myRoom.roomies
                        .firstWhere((roomie) => roomie.id != user.uid);
                  }
                  return userDashboardContainer(roomie.points, actions,
                      roomsdata.myRoom, roomie.id, isRoomie);
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

  Widget userDashboardContainer(points, List<Map<String, Object>> actions,
      Room room, String userId, bool isRoomie) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      margin: EdgeInsets.all(8),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: FittedBox(
                  child: Text(
                    '${points.toString()} pkt',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
          if (isRoomie)
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                      child: Text(
                        'Save your roomie activity',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Expanded(
                      child: GridView(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 3 / 3,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                        children: [
                          ActionItem(
                            'Save Activity',
                            SaveActivityScreen.routeName,
                            'assets/images/cleaning.png',
                            userId,
                            Color.fromRGBO(236, 32, 73, 0.5),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          if (!isRoomie)
            Expanded(
              flex: 3,
              //height: 460,
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
