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
        borderRadius: BorderRadius.circular(18),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 5,
          //color: routeName == '' ? Colors.grey : color,
          margin: EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              //border: Border.all(color: color, width: 3),
              // gradient: LinearGradient(
              //     begin: Alignment.bottomRight,
              //     end: Alignment.topLeft,
              //     colors: [
              //       color.withOpacity(1),
              //       color.withOpacity(0.9),
              //       color.withOpacity(0.3)
              //     ]),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: routeName == ''
                    ? ColorFiltered(
                        colorFilter:
                            ColorFilter.mode(Colors.grey, BlendMode.saturation),
                        child: Image.asset(imagePath,
                            height: 60, width: 60, fit: BoxFit.cover),
                      )
                    : Image.asset(
                        imagePath,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        color: color.withOpacity(1),
                      ),
              ),
              SizedBox(
                height: 2,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ]),
          ),
        ));
  }
}
