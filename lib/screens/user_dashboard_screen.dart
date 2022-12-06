import '../screens/save_activity_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_has_no_room.dart';
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
  var _isInit = true;
  void _joinToRoom(Room selectedRoom) {
    Provider.of<RoomsProvider>(context, listen: false)
        .joinToRoom(selectedRoom)
        .then((_) {});
  }

  void _createdRoom() {}

  Future<void> _tryGetYourRoom() async {
    await Provider.of<RoomsProvider>(context, listen: false)
        .getYourRoom(roomie.id);
  }

  @override
  void didChangeDependencies() {
    print('didchangeDependencies');
    if (_isInit) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      if (routeArgs != null) {
        final userId = routeArgs['userId'];
        final name = routeArgs['name'];
        final imageUrl = routeArgs['imageUrl'];
        final points = routeArgs['points'];

        roomie = Roomie(
            id: userId, userName: name, points: points, imageUrl: imageUrl);
      } else {
        print('routeArgs null');
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
    Room room;

    final actions = [
      {
        'title': 'Save Activity',
        'routeName': SaveActivityScreen.routeName,
        'imagePath': 'assets/images/cleaning.png'
      },
      {
        'title': 'Money balance',
        'routeName': '/', //ExchangeToPrize.routeName,
        'imagePath': 'assets/images/money.png'
      },
      {
        'title': 'Prizes',
        'routeName': '/', //MyPrizesScreen.routeName,
        'imagePath': 'assets/images/myPrize.png'
      },
      {
        'title': 'Stats',
        'routeName': '/', //StatsScreen.routeName,
        'imagePath': 'assets/images/stats.png'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        //title: Text(name),
        title: Text(roomie.userName),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _tryGetYourRoom(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Consumer<RoomsProvider>(
              builder: ((context, roomsdata, _) {
                if (roomsdata.myRoom != null) {
                  if (roomie.points == null) {
                    roomie = roomsdata.myRoom.roomies
                        .firstWhere((roomie) => roomie.id == user.uid);
                  }
                  return userDashboardContainer(
                      //points, actions, roomsdata.myRoom);
                      roomie.points,
                      actions,
                      roomsdata.myRoom,
                      roomie.id);
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
      points, List<Map<String, String>> actions, Room room, String userId) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            child: Text(
              '${points.toString()} pkt',
              style: TextStyle(fontSize: 20),
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(UserRoomScreen.routeName)
                    .then((_) {
                  setState(() {});
                });
              },
              icon: Icon(Icons.home)),
          Text(
            'Point summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 460,
            child: GridView(
              padding: const EdgeInsets.all(10),
              children: actions
                  .map(
                    (action) => ActionItem(
                      action['title'] as String,
                      action['routeName'] as String,
                      action['imagePath'] as String,
                      userId,
                    ),
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
        ],
      ),
    );
  }
}
