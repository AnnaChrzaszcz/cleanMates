import 'package:clean_mates_app/models/gift.dart';
import 'package:clean_mates_app/models/room.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rooms_provider.dart';

class UserGiftContainer extends StatelessWidget {
  final String userId;
  List<Gift> gifts;

  UserGiftContainer(@required this.userId, @required this.gifts);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300])),
        child: Text('${gifts.length}')
        // child: ListView.builder(
        //   itemCount: gifts.length,
        //   itemBuilder: ((context, index) => ListTile(
        //         title: Text(gifts[index].giftName),
        //       )),
        // ),
        );
  }
}
