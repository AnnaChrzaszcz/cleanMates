import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:clean_mates_app/widgets/user_has_no_room.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/action_item.dart';
import '../repositories/room_repository.dart';
import '../models/room.dart';
import '../screens/user_room_screen.dart';
import '../providers/rooms_provider.dart';
import 'package:provider/provider.dart';

class UserDashboardScreen extends StatefulWidget {
  static const String routeName = '/userDashboard';
  final user = FirebaseAuth.instance.currentUser;

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final roomRepo = RoomRepository();

  void _joinToRoom(Room selectedRoom) {
    Provider.of<RoomsProvider>(context, listen: false)
        .joinToRoom(selectedRoom)
        .then((_) {
      _tryGetYourRoom();
      setState(() {});
    });
  }

  void _createdRoom() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //_tryGetYourRoom();
  }

  Future<void> _tryGetYourRoom() async {
    await Provider.of<RoomsProvider>(context, listen: false)
        .getYourRoom(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user.displayName;
    final url = widget.user.photoURL;
    final points = 0;
    Room room;

    final actions = [
      {
        'title': 'Save Activity',
        'routeName': '/', //SaveActivityScreen.routeName
        'imagePath': 'assets/images/cleaning.png'
      },
      {
        'title': 'Exchange To Prize',
        'routeName': '/', //ExchangeToPrize.routeName,
        'imagePath': 'assets/images/prize.png'
      },
      {
        'title': 'Lista moich nagród',
        'routeName': '/', //MyPrizesScreen.routeName,
        'imagePath': 'assets/images/myPrize.png'
      },
      {
        'title': 'Statystyki',
        'routeName': '/', //StatsScreen.routeName,
        'imagePath': 'assets/images/stats.png'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
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
                  return userDashboardContainer(
                      points, actions, roomsdata.myRoom);
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
      points, List<Map<String, String>> actions, Room room) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircleAvatar(
            radius: 40,
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
                        action['imagePath'] as String),
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
