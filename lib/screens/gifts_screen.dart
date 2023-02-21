import 'package:clean_mates_app/models/room.dart';
import 'package:clean_mates_app/providers/gifts_provider.dart';

import 'package:clean_mates_app/screens/edit_gift_screen.dart';

import 'package:clean_mates_app/widgets/fab/custom_add_fab.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import '../providers/rooms_provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class GiftsScreen extends StatelessWidget {
  static const routeName = '/gifts';

  Future<void> _refreshGifts(BuildContext context, String roomId) async {
    await Provider.of<GiftsProvider>(context, listen: false)
        .fetchAndSetData(roomId);
  }

  void _deleteGift(BuildContext context, String id) async {
    try {
      await Provider.of<GiftsProvider>(context, listen: false).deleteGift(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gift deleted!',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
    Room myRoom = Provider.of<RoomsProvider>(context).myRoom;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Gifts overview'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          CustomAddFab(activityScreen: false, roomId: myRoom.id),
      body: FutureBuilder(
        future: _refreshGifts(context, myRoom.id),
        builder: ((context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : CustomRefreshIndicator(
                onRefresh: () => _refreshGifts(context, myRoom.id),
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
                child: Consumer<GiftsProvider>(
                  builder: ((ctx, giftsData, _) => giftsData.gifts.isEmpty
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
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
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
                                                      'id': giftsData
                                                          .gifts[index].id,
                                                    });
                                              },
                                            ),
                                            IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (ctx) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          'Are you sure?'),
                                                      content: const Text(
                                                          'Do you want to remove this gift?'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'NO')),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                              _deleteGift(
                                                                  context,
                                                                  giftsData
                                                                      .gifts[
                                                                          index]
                                                                      .id);
                                                            },
                                                            child: const Text(
                                                                'YES')),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                        leading: CircleAvatar(
                                            radius: 25,
                                            backgroundColor:
                                                Theme.of(context).dividerColor,
                                            foregroundColor: Colors.white,
                                            child: FittedBox(
                                              child: Icon(IconData(
                                                  (giftsData
                                                      .gifts[index].iconCode),
                                                  fontFamily: 'MaterialIcons')),
                                            )),
                                        title: Text(
                                          giftsData.gifts[index].giftName,
                                          style: const TextStyle(),
                                        ),
                                        subtitle: Text(
                                            '${giftsData.gifts[index].points} points')),
                                    const Divider()
                                  ],
                                )),
                          ),
                        )),
                ),
              )),
      ),
    );
  }
}
