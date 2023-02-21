import 'package:clean_mates_app/screens/save_activity_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../screens/user_dashboard_screen.dart';

class RoomieItem extends StatelessWidget {
  final String userId;
  final String name;
  final String imageUrl;
  final int points;

  RoomieItem(this.userId, this.name, this.imageUrl, this.points);

  void _selectUser(BuildContext ctx) {
    Navigator.of(ctx).pushReplacementNamed(UserDashboardScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    return GestureDetector(
      onTap: name == user.displayName ? () => _selectUser(context) : () {},
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        elevation: 30,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color.fromRGBO(247, 219, 79, 1),
                    child: CircleAvatar(
                        radius: 42, backgroundImage: NetworkImage(imageUrl)),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.headline4,
                        ),
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
            const SizedBox(
              height: 15,
            ),
            if (name != user.displayName)
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                      SaveActivityScreen.routeName,
                      arguments: userId),
                  child: Text('Save activity as $name'))
          ]),
        ),
      ),
    );
  }
}
