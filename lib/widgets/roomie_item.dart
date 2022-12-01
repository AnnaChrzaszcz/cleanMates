import 'package:flutter/material.dart';
import '../screens/user_dashboard_screen.dart';

class RoomieItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final int points;

  RoomieItem(this.name, this.imageUrl, this.points);

  void selectUser(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(UserDashboardScreen.routeName,
        arguments: {'name': name, 'imageUrl': imageUrl, 'points': points});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20)),
      height: 170,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GridTile(
          child: GestureDetector(
            onTap: () {
              selectUser(context);
            },
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          footer: Container(
            padding: EdgeInsets.all(10),
            color: Colors.black54,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                name,
                style: TextStyle(color: Colors.white),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
