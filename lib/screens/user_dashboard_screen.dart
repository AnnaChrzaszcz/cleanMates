import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/action_item.dart';

class UserDashboardScreen extends StatelessWidget {
  static const String routeName = '/userDashboard';
  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final name = routeArgs['name'] as String;
    final url = routeArgs['imageUrl'] as String;
    final points = routeArgs['points'];

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
        body: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
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
        ));
  }
}
