import 'package:clean_mates_app/models/room.dart';
import 'package:clean_mates_app/providers/gifts_provider.dart';
import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/screens/edit_gift_screen.dart';
import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
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

  void _goToNewGift(BuildContext context, Room myRoom) {
    Navigator.of(context)
        .pushNamed(EditGiftScreen.routeName, arguments: {'roomId': myRoom.id});
  }

  @override
  Widget build(BuildContext context) {
    Room myRoom = Provider.of<RoomsProvider>(context).myRoom;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToNewGift(context, myRoom),
        child: Icon(Icons.add),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshGifts(context, myRoom.id),
        builder: ((context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : CustomRefreshIndicator(
                onRefresh: () => _refreshGifts(context, myRoom.id),
                builder: MaterialIndicatorDelegate(
                  builder: (context, controller) {
                    return const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color.fromRGBO(47, 149, 153, 1),
                      child: RiveAnimation.asset(
                        'assets/animations/indicator.riv',
                      ),
                    );
                  },
                ),
                child: Consumer<GiftsProvider>(
                  builder: ((ctx, giftsData, _) => Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        child: ListView.builder(
                          itemCount: giftsData.gifts.length,
                          itemBuilder: ((context, index) => Column(
                                children: [
                                  ListTile(
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                                EditGiftScreen.routeName,
                                                arguments: {
                                                  'id':
                                                      giftsData.gifts[index].id,
                                                });
                                          },
                                        ),
                                        IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: Text('Are you sure?'),
                                                  content: Text(
                                                      'Do you want to remove the item from the cart?'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(ctx)
                                                              .pop();
                                                        },
                                                        child: Text('NO')),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(ctx)
                                                              .pop();
                                                          _deleteGift(
                                                              context,
                                                              giftsData
                                                                  .gifts[index]
                                                                  .id);
                                                        },
                                                        child: Text('YES')),
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
                                          child: Text(
                                              '${giftsData.gifts[index].points}'),
                                        )),
                                    title: Text(
                                      giftsData.gifts[index].giftName,
                                      style: TextStyle(),
                                    ),
                                    subtitle: Text(myRoom.roomName),
                                  ),
                                  Divider()
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
