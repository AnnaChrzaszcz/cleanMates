import 'package:clean_mates_app/models/gift.dart';
import 'package:clean_mates_app/models/userGift.dart';
import 'package:clean_mates_app/widgets/gift/user_gift_container.dart';

import '../widgets/gift/buy_gift_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rooms_provider.dart';
import '../providers/gifts_provider.dart';

class BuyGiftScreen extends StatelessWidget {
  static const routeName = '/buyGift';

  Future<void> _refreshGifts(BuildContext context, String roomId) async {
    await Provider.of<GiftsProvider>(context, listen: false)
        .fetchAndSetData(roomId);
  }

  @override
  Widget build(BuildContext context) {
    //POPRAWIC JAK JEST JEDEN USER GLOWNY TYLKO!!!!!
    var myRoom = Provider.of<RoomsProvider>(context, listen: false).myRoom;
    final userId = ModalRoute.of(context).settings.arguments as String;
    final roomieId =
        myRoom.roomies.firstWhere((roomie) => roomie.id != userId).id;

    List<UserGift> userGifts =
        Provider.of<RoomsProvider>(context, listen: false)
            .getUserGifts(userId); //tu id usera
    List<UserGift> roomieGifts =
        Provider.of<RoomsProvider>(context, listen: false)
            .getUserGifts(roomieId); //tu id roomie

    return Scaffold(
      appBar: AppBar(title: Text('Buy gifts')),
      body: FutureBuilder(
        future: _refreshGifts(context, myRoom.id),
        builder: ((context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Consumer<GiftsProvider>(
                    builder: ((ctx, gitsData, _) => Column(
                          children: [
                            BuyGiftContainer(gitsData.gifts, userId),
                            UserGiftContainer(
                                userId, roomieId, userGifts, roomieGifts)
                          ],
                        )),
                  )),
      ),
    );
  }
}
