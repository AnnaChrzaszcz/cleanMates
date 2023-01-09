import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../screens/user_dashboard_screen.dart';

class RoomieItem extends StatelessWidget {
  final String userId;
  final String name;
  final String imageUrl;
  final int points;

  RoomieItem(this.userId, this.name, this.imageUrl, this.points);

  void selectUser(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(UserDashboardScreen.routeName, arguments: {
      'userId': userId,
      'name': name,
      'imageUrl': imageUrl,
      'points': points
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      elevation: 30,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(children: [
          Row(
            children: [
              Expanded(
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Color.fromRGBO(247, 219, 79, 1),
                  child: CircleAvatar(
                      radius: 42,
                      backgroundImage: NetworkImage(
                          userId == FirebaseAuth.instance.currentUser.uid
                              ? FirebaseAuth.instance.currentUser.photoURL
                              : imageUrl)),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text(
                      '${points.toString()} points',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
              onPressed: () => selectUser(context),
              child: Text('Go to profile'))
        ]),
      ),
    );
  }
}
