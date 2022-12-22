import 'package:clean_mates_app/models/userGift.dart';
import 'package:clean_mates_app/widgets/gift/tab_bar_view_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rooms_provider.dart';

class UserGiftContainer extends StatefulWidget {
  final String userId;
  final String roomieId;
  final String yourUsername;
  final String roomieUsername;
  List<UserGift> userGifts;
  List<UserGift> roomieGifts;

  UserGiftContainer(
      @required this.userId,
      @required this.roomieId,
      @required this.yourUsername,
      @required this.roomieUsername,
      @required this.userGifts,
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
    Navigator.of(context).pop();
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
                      Tab(text: widget.yourUsername),
                      Tab(text: widget.roomieUsername),
                    ],
                  ),
                ),
                Flexible(
                  child: TabBarView(
                    children: <Widget>[
                      TabBarViewContainer(
                          yourBought, yourRecived, _receive, widget.userId),
                      TabBarViewContainer(roomieBought, roomieRecived, _receive,
                          widget.roomieId),
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
