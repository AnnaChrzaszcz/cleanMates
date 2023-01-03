import 'package:flutter/material.dart';

class ActionItem extends StatelessWidget {
  final String title;
  final String routeName;
  final String imagePath;
  final String userId;
  final Color color;

  ActionItem(
      this.title, this.routeName, this.imagePath, this.userId, this.color);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: routeName == ''
            ? null
            : () {
                Navigator.of(context).pushNamed(routeName, arguments: userId);
              },
        splashColor: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(40),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 5,
          color: routeName == '' ? Colors.grey : color,
          margin: EdgeInsets.all(10),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: routeName == ''
                  ? ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(Colors.grey, BlendMode.saturation),
                      child: Image.asset(imagePath,
                          height: 60, width: 60, fit: BoxFit.cover),
                    )
                  : Image.asset(imagePath,
                      height: 60, width: 60, fit: BoxFit.cover),
            ),
            SizedBox(
              height: 2,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: Text(
                title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            )
          ]),
        ));
  }
}
