import 'dart:math';
import 'package:clean_mates_app/models/userGift.dart';
import 'package:clean_mates_app/widgets/gift/tab_bar_view_container.dart';
import 'package:intl/intl.dart';
import 'package:clean_mates_app/models/gift.dart';
import 'package:clean_mates_app/models/room.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rooms_provider.dart';

class UserGiftContainer extends StatefulWidget {
  final String userId;
  List<UserGift> userGifts;
  List<UserGift> roomieGifts;

  UserGiftContainer(@required this.userId, @required this.userGifts,
      @required this.roomieGifts);

  @override
  State<UserGiftContainer> createState() => _UserGiftContainerState();
}

class _UserGiftContainerState extends State<UserGiftContainer> {
  var _boughtExpanded = false;
  var _recivedExpanded = false;
  List<UserGift> yourRecived;
  List<UserGift> yourBought;
  List<UserGift> roomieRecived;
  List<UserGift> roomieBought;
  var yourSelectedIndex = -1;

  @override
  void initState() {
    yourRecived = widget.userGifts.where((gift) => gift.isRealized).toList();
    yourBought = widget.userGifts.where((gift) => !gift.isRealized).toList();
    roomieRecived =
        widget.roomieGifts.where((gift) => gift.isRealized).toList();
    roomieBought =
        widget.roomieGifts.where((gift) => !gift.isRealized).toList();
    super.initState();
  }

  void _receive(String userId, selectedIndex) {
    var giftId;

    if (userId == 'you') {
      //poprawic potem
      print(yourBought[selectedIndex].gift.giftName);
      giftId = yourBought[selectedIndex].id;
    } else {
      print(roomieBought[selectedIndex].gift.giftName);
      giftId = roomieBought[selectedIndex].id;
    }
    Provider.of<RoomsProvider>(context, listen: false)
        .markUserGiftAsRecived(userId, giftId);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: DefaultTabController(
          length: 2, // length of tabs
          initialIndex: 0,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  child: TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.black,
                    tabs: [
                      Tab(text: 'You'),
                      Tab(text: 'Roomie'),
                    ],
                  ),
                ),
                Flexible(
                  child: TabBarView(
                    children: <Widget>[
                      TabBarViewContainer(
                          yourBought, yourRecived, _receive, 'you'),
                      TabBarViewContainer(
                          roomieBought, roomieRecived, _receive, 'roomie'),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
