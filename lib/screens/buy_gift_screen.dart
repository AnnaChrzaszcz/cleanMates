import 'package:clean_mates_app/models/userGift.dart';
import 'package:clean_mates_app/screens/edit_gift_screen.dart';
import 'package:clean_mates_app/screens/gifts_screen.dart';
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
    var myRoom = Provider.of<RoomsProvider>(context, listen: false).myRoom;
    final userId = ModalRoute.of(context).settings.arguments as String;
    var roomieId;
    var roomieUsername;
    var yourUsername;
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
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Buy gifts'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditGiftScreen.routeName,
                    arguments: {'roomId': myRoom.id});
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: myRoom.roomies.length == 1
          ? Center(
              child: Text(
                'You need to add a roomie to your room',
                style: Theme.of(context).textTheme.headline6,
              ),
            )
          : FutureBuilder(
              future: _refreshGifts(context, myRoom.id),
              builder: ((context, snapshot) => snapshot.connectionState ==
                      ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Consumer<GiftsProvider>(
                      builder: ((ctx, gitsData, _) => Column(
                            children: [
                              gitsData.gifts.length == 0
                                  ? Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 10),
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'You need at least one gift in your dictionary',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6,
                                              textAlign: TextAlign.center,
                                            ),
                                            TextButton(
                                                onPressed: () => Navigator.of(
                                                        context)
                                                    .pushReplacementNamed(
                                                        GiftsScreen.routeName),
                                                child: Text(
                                                    'Go to gift dictionary'))
                                          ],
                                        ),
                                      ),
                                    )
                                  : BuyGiftContainer(gitsData.gifts, userId),
                              UserGiftContainer(userId, roomieId, yourUsername,
                                  roomieUsername, userGifts, roomieGifts)
                            ],
                          )),
                    )),
            ),
    );
  }
}
