import 'package:clean_mates_app/models/userGift.dart';
import 'package:clean_mates_app/screens/gifts_reception_screen.dart';
import 'package:clean_mates_app/widgets/gift/tab_bar_view_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rooms_provider.dart';

class UserGiftContainer extends StatefulWidget {
  final String userId;
  final String roomieId;
  final String yourUsername;
  final String roomieUsername;
  List<UserGift> gifts;

  UserGiftContainer(
      @required this.userId,
      @required this.roomieId,
      @required this.yourUsername,
      @required this.roomieUsername,
      @required this.gifts);

  @override
  State<UserGiftContainer> createState() => _UserGiftContainerState();
}

class _UserGiftContainerState extends State<UserGiftContainer> {
  List<UserGift> userGifts;
  List<UserGift> roomieGifts;
  List<UserGift> yourRecived;
  List<UserGift> yourBought;
  List<UserGift> roomieRecived;
  List<UserGift> roomieBought;
  var yourSelectedIndex = -1;

  @override
  void initState() {
    userGifts = widget.gifts
        .where((roomieGift) => roomieGift.roomieId == widget.userId)
        .toList();
    roomieGifts = widget.gifts
        .where((roomieGift) => roomieGift.roomieId == widget.roomieId)
        .toList();
    yourRecived = userGifts.where((gift) => gift.isRealized).toList();
    yourBought = userGifts.where((gift) => !gift.isRealized).toList();
    roomieRecived = roomieGifts.where((gift) => gift.isRealized).toList();
    roomieBought = roomieGifts.where((gift) => !gift.isRealized).toList();
    super.initState();
  }

  void _receive(String userId, selectedIndex) async {
    var giftId;

    if (userId == widget.userId) {
      //poprawic potem
      print(yourBought[selectedIndex].giftName);
      giftId = yourBought[selectedIndex].id;
    } else {
      print(roomieBought[selectedIndex].giftName);
      giftId = roomieBought[selectedIndex].id;
    }
    await Provider.of<RoomsProvider>(context, listen: false)
        .markUserGiftAsRecived(userId, giftId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gift received!'),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      userGifts = widget.gifts
          .where((roomieGift) => roomieGift.roomieId == widget.userId)
          .toList();
      roomieGifts = widget.gifts
          .where((roomieGift) => roomieGift.roomieId == widget.roomieId)
          .toList();
      yourRecived = userGifts.where((gift) => gift.isRealized).toList();
      yourBought = userGifts.where((gift) => !gift.isRealized).toList();
      roomieRecived = roomieGifts.where((gift) => gift.isRealized).toList();
      roomieBought = roomieGifts.where((gift) => !gift.isRealized).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
                  Tab(text: widget.roomieUsername),
                  Tab(text: widget.yourUsername),
                ],
              ),
            ),
            Flexible(
              child: TabBarView(
                children: <Widget>[
                  TabBarViewContainer(
                      widget.gifts
                          .where((roomieGift) =>
                              roomieGift.roomieId == widget.roomieId)
                          .where((gift) => !gift.isRealized)
                          .toList(),
                      widget.gifts
                          .where((roomieGift) =>
                              roomieGift.roomieId == widget.roomieId)
                          .where((gift) => gift.isRealized)
                          .toList(),
                      _receive,
                      widget.roomieId),
                  TabBarViewContainer(
                      widget.gifts
                          .where((roomieGift) =>
                              roomieGift.roomieId == widget.userId)
                          .where((gift) => !gift.isRealized)
                          .toList(),
                      widget.gifts
                          .where((roomieGift) =>
                              roomieGift.roomieId == widget.userId)
                          .where((gift) => gift.isRealized)
                          .toList(),
                      _receive,
                      widget.userId),
                ],
              ),
            ),
          ]),
    );
  }
}
