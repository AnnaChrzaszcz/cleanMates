import 'package:clean_mates_app/models/userGift.dart';
import 'package:clean_mates_app/screens/edit_gift_screen.dart';
import 'package:clean_mates_app/screens/gifts_screen.dart';
import 'package:clean_mates_app/widgets/gift/user_gift_container.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';

import '../widgets/gift/buy_gift_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rooms_provider.dart';
import '../providers/gifts_provider.dart';

class BuyGiftScreen extends StatelessWidget {
  static const routeName = '/buyGift';

  Future<void> _refreshGifts(
      BuildContext context, String roomId, String userId) async {
    await Provider.of<GiftsProvider>(context, listen: false)
        .fetchAndSetData(roomId);
    await Provider.of<RoomsProvider>(context, listen: false)
        .getUserRoom(userId);
  }

  @override
  Widget build(BuildContext context) {
    var myRoom = Provider.of<RoomsProvider>(context, listen: false).myRoom;
    final userId = ModalRoute.of(context).settings.arguments as String;
    var roomieId;
    var roomieUsername;
    var yourUsername;
    var yourPoints;
    List<UserGift> userGifts = [];
    List<UserGift> roomieGifts = [];

    if (myRoom.roomies.length > 1) {
      roomieId = myRoom.roomies.firstWhere((roomie) => roomie.id != userId).id;
      userGifts = Provider.of<RoomsProvider>(context, listen: false)
          .getUserGifts(userId); //tu id usera
      roomieGifts = Provider.of<RoomsProvider>(context, listen: false)
          .getUserGifts(roomieId); //tu id roomie
      roomieUsername =
          myRoom.roomies.firstWhere((roomie) => roomie.id != userId).userName;
      yourUsername =
          myRoom.roomies.firstWhere((roomie) => roomie.id == userId).userName;
      yourPoints =
          myRoom.roomies.firstWhere((roomie) => roomie.id == userId).points;
    }

    return FutureBuilder(
      future: _refreshGifts(context, myRoom.id, userId),
      builder: ((context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? Scaffold(
              appBar: AppBar(title: const Text('Buy gifts')),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Consumer<GiftsProvider>(
              builder: ((ctx, gitsData, _) => Scaffold(
                  appBar: AppBar(
                    title: Text('Buy gifts'),
                    actions: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                EditGiftScreen.routeName,
                                arguments: {'roomId': myRoom.id});
                          },
                          icon: gitsData.gifts.isEmpty
                              ? Lottie.asset(
                                  'assets/animations/lottie/add2.json')
                              : Icon(Icons.add))
                    ],
                  ),
                  body: myRoom.roomies.length == 1
                      ? Center(
                          child: Text(
                            'You need to add a roomie to your room',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        )
                      : gitsData.gifts.isEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 30, horizontal: 10),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 30, horizontal: 30),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'You need at least one gift in your gifts overview',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextButton(
                                      onPressed: () => Navigator.of(context)
                                          .pushNamed(EditGiftScreen.routeName,
                                              arguments: {'roomId': myRoom.id}),
                                      child: Text(
                                        'Click the above "+" to add new gift',
                                        style: TextStyle(fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ))
                                ],
                              ),
                            )
                          : BuyGiftContainer(
                              gitsData.gifts,
                              userId,
                              yourPoints,
                              () =>
                                  _refreshGifts(context, myRoom.id, userId)))),
            )),
    );
  }
}
