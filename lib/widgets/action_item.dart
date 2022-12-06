import 'package:flutter/material.dart';

class ActionItem extends StatelessWidget {
  final String title;
  final String routeName;
  final String imagePath;
  final String userId;

  ActionItem(this.title, this.routeName, this.imagePath, this.userId);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(routeName, arguments: userId);
        },
        splashColor: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(15),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(imagePath,
                  height: 60, width: 60, fit: BoxFit.cover),
            ),
            SizedBox(
              height: 2,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Text(
                title,
                style: TextStyle(fontSize: 13),
              ),
            )
          ]),
        ));
  }
}
