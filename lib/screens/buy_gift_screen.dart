import 'package:clean_mates_app/models/room.dart';
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
      future: _refreshGifts(context, myRoom.id),
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
                  appBar: AppBar(title: const Text('Buy gifts')),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endFloat,
                  floatingActionButton: FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    onPressed: () => _goToNewGift(context, myRoom),
                    child: Icon(Icons.add),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(8),
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
                                  Tab(text: 'Buy gift'),
                                  Tab(text: 'Gifts overview'),
                                ],
                              ),
                            ),
                            Flexible(
                              child: TabBarView(
                                children: <Widget>[
                                  myRoom.roomies.length == 1
                                      ? Center(
                                          child: Text(
                                            'You need to add a roomie to your room',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : gitsData.gifts.isEmpty
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 30,
                                                      horizontal: 10),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 30,
                                                      horizontal: 30),
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'You need at least one gift in your gifts overview',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  TextButton(
                                                      onPressed: () => {
                                                            Navigator.of(
                                                                    context)
                                                                .pushNamed(
                                                                    EditGiftScreen
                                                                        .routeName,
                                                                    arguments: {
                                                                  'roomId':
                                                                      myRoom.id
                                                                })
                                                          },
                                                      child: Text(
                                                        'Click the "+" below to add new gift',
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ))
                                                ],
                                              ),
                                            )
                                          : BuyGiftContainer(gitsData.gifts,
                                              userId, yourPoints),
                                  gitsData.gifts.isEmpty
                                      ? Container(
                                          padding: EdgeInsets.all(8.0),
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                'You have no gifts yet',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5,
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Text(
                                                'Define some gifts below (+)',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6,
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 8),
                                          child: ListView.builder(
                                            itemCount: gitsData.gifts.length,
                                            itemBuilder:
                                                ((context, index) => Column(
                                                      children: [
                                                        ListTile(
                                                            trailing: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .edit),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(context).pushNamed(
                                                                        EditGiftScreen
                                                                            .routeName,
                                                                        arguments: {
                                                                          'id': gitsData
                                                                              .gifts[index]
                                                                              .id,
                                                                        });
                                                                  },
                                                                ),
                                                                IconButton(
                                                                    icon: Icon(Icons
                                                                        .delete),
                                                                    onPressed:
                                                                        () {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (ctx) =>
                                                                                AlertDialog(
                                                                          title:
                                                                              Text('Are you sure?'),
                                                                          content:
                                                                              Text('Do you want to remove this gift?'),
                                                                          actions: [
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(ctx).pop();
                                                                                },
                                                                                child: Text('NO')),
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(ctx).pop();
                                                                                  _deleteGift(context, gitsData.gifts[index].id);
                                                                                },
                                                                                child: Text('YES')),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }),
                                                              ],
                                                            ),
                                                            leading:
                                                                CircleAvatar(
                                                                    radius: 25,
                                                                    backgroundColor:
                                                                        Theme.of(context)
                                                                            .dividerColor,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    child:
                                                                        FittedBox(
                                                                      child: Icon(IconData(
                                                                          (gitsData
                                                                              .gifts[
                                                                                  index]
                                                                              .iconCode),
                                                                          fontFamily:
                                                                              'MaterialIcons')),
                                                                    )),
                                                            title: Text(
                                                              gitsData
                                                                  .gifts[index]
                                                                  .giftName,
                                                              style:
                                                                  TextStyle(),
                                                            ),
                                                            subtitle: Text(
                                                                '${gitsData.gifts[index].points} points')),
                                                        Divider()
                                                      ],
                                                    )),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  ))),
            )),
    );
  }
}
