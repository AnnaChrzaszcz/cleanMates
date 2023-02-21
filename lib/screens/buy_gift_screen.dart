import 'package:clean_mates_app/models/room.dart';
import 'package:clean_mates_app/screens/edit_gift_screen.dart';
import 'package:clean_mates_app/widgets/fab/custom_add_fab.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    var myRoom = Provider.of<RoomsProvider>(context, listen: false).myRoom;
    final userId = ModalRoute.of(context).settings.arguments as String;

    int yourPoints;

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    yourPoints =
        myRoom.roomies.firstWhere((roomie) => roomie.id == userId).points;

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
                builder: ((ctx, giftsData, _) => Scaffold(
                    key: scaffoldKey,
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.endFloat,
                    floatingActionButton:
                        CustomAddFab(activityScreen: false, roomId: myRoom.id),
                    appBar: AppBar(
                      title: const Text('Buy gifts'),
                    ),
                    body: CustomRefreshIndicator(
                      builder: MaterialIndicatorDelegate(
                        builder: (context, controller) {
                          return const CircleAvatar(
                            radius: 60,
                            backgroundColor: Color.fromRGBO(47, 149, 153, 1),
                            child: RiveAnimation.asset(
                              'assets/animations/indicator.riv',
                            ),
                          );
                        },
                      ),
                      onRefresh: () =>
                          _refreshGifts(context, myRoom.id, userId),
                      child: buyGifts(
                          giftsData, context, myRoom, userId, yourPoints),
                    ))),
              )));
  }

  Widget buyGifts(GiftsProvider giftsData, BuildContext context, Room myRoom,
      String userId, yourPoints) {
    return myRoom.roomies.length == 1
        ? Center(
            child: Text(
              'You need to add a roomie to your room',
              style: Theme.of(context).textTheme.headline6,
            ),
          )
        : giftsData.gifts.isEmpty
            ? Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                margin:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You need at least one gift in your gifts overview',
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                            EditGiftScreen.routeName,
                            arguments: {'roomId': myRoom.id}),
                        child: const Text(
                          'Click the "+"  below to add new gifts',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ))
                  ],
                ),
              )
            : BuyGiftContainer(giftsData.gifts, userId, yourPoints,
                () => _refreshGifts(context, myRoom.id, userId));
  }
}
