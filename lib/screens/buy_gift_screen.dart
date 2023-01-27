import 'package:clean_mates_app/models/room.dart';
import 'package:clean_mates_app/screens/edit_gift_screen.dart';
import 'package:clean_mates_app/widgets/fab/custom_add_fab.dart';
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
  }

  void _deleteGift(BuildContext context, String id) async {
    try {
      await Provider.of<GiftsProvider>(context, listen: false).deleteGift(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gift deleted!',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deleting failed!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var myRoom = Provider.of<RoomsProvider>(context, listen: false).myRoom;
    final userId = ModalRoute.of(context).settings.arguments as String;

    var yourPoints;

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
                      key: _scaffoldKey,
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.endFloat,
                      floatingActionButton: CustomAddFab(
                          activityScreen: false, roomId: myRoom.id),
                      appBar: AppBar(
                        title: Text('Buy gifts'),
                      ),
                      body: DefaultTabController(
                        length: 2, // length of tabs
                        initialIndex: 0,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                child: TabBar(
                                  labelColor: Theme.of(context).primaryColor,
                                  unselectedLabelColor: Colors.black,
                                  tabs: const [
                                    Tab(text: 'Buy gifts'),
                                    Tab(text: 'Gifts overview'),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: TabBarView(
                                  children: <Widget>[
                                    buyGifts(giftsData, context, myRoom, userId,
                                        yourPoints),
                                    CustomRefreshIndicator(
                                        onRefresh: () => _refreshGifts(
                                            context, myRoom.id, userId),
                                        builder: MaterialIndicatorDelegate(
                                          builder: (context, controller) {
                                            return const CircleAvatar(
                                              radius: 60,
                                              backgroundColor: Color.fromRGBO(
                                                  47, 149, 153, 1),
                                              child: RiveAnimation.asset(
                                                'assets/animations/indicator.riv',
                                              ),
                                            );
                                          },
                                        ),
                                        child:
                                            giftsOverview(giftsData, context)),
                                  ],
                                ),
                              ),
                            ]),
                      ),
                    )),
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

  Container giftsOverview(GiftsProvider giftsData, BuildContext context) {
    return giftsData.gifts.isEmpty
        ? Container(
            padding: EdgeInsets.all(8.0),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'You have no gifts yet',
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  'Define some gifts below (+)',
                  style: Theme.of(context).textTheme.headline6,
                ),
                RotatedBox(
                    quarterTurns: 2,
                    child: Container(
                      width: double.infinity * 1 / 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 40, horizontal: 10),
                      child: Lottie.asset(
                        'assets/animations/lottie/box.json',
                        fit: BoxFit.contain,
                      ),
                    )),
              ],
            ),
          )
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ListView.builder(
              itemCount: giftsData.gifts.length,
              itemBuilder: ((context, index) => Column(
                    children: [
                      ListTile(
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                      EditGiftScreen.routeName,
                                      arguments: {
                                        'id': giftsData.gifts[index].id,
                                      });
                                },
                              ),
                              IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Are you sure?'),
                                        content: const Text(
                                            'Do you want to remove this gift?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text('NO')),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                                _deleteGift(context,
                                                    giftsData.gifts[index].id);
                                              },
                                              child: const Text('YES')),
                                        ],
                                      ),
                                    );
                                  }),
                            ],
                          ),
                          leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Theme.of(context).dividerColor,
                              foregroundColor: Colors.white,
                              child: FittedBox(
                                child: Icon(IconData(
                                    (giftsData.gifts[index].iconCode),
                                    fontFamily: 'MaterialIcons')),
                              )),
                          title: Text(
                            giftsData.gifts[index].giftName,
                          ),
                          subtitle:
                              Text('${giftsData.gifts[index].points} points')),
                      const Divider()
                    ],
                  )),
            ),
          );
  }
}
