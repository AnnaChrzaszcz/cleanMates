import 'package:clean_mates_app/models/room.dart';
import 'package:clean_mates_app/providers/gifts_provider.dart';
import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/screens/edit_gift_screen.dart';
import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rooms_provider.dart';

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
        title: Text('Gifts overview'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => _goToNewGift(context, myRoom),
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _refreshGifts(context, myRoom.id),
        builder: ((context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<GiftsProvider>(
                builder: ((ctx, giftsData, _) => giftsData.gifts.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(8.0),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'You have no gifts yet',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Define some gifts below (+)',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ],
                        ),
                      )
                    : Container(
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
                                                    'id': giftsData
                                                        .gifts[index].id,
                                                  });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () => _deleteGift(
                                                context,
                                                giftsData.gifts[index].id),
                                          ),
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
                                        style: TextStyle(),
                                      ),
                                      subtitle: Text(
                                          '${giftsData.gifts[index].points} points')),
                                  Divider()
                                ],
                              )),
                        ),
                      )),
              )),
      ),
    );
  }
}
