import 'package:clean_mates_app/models/userGift.dart';
import 'package:clean_mates_app/widgets/app_drawer.dart';
import 'package:clean_mates_app/widgets/gift/user_gift_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rooms_provider.dart';
import '../providers/gifts_provider.dart';

class RecivedGiftsScreen extends StatelessWidget {
  static const routeName = '/recivedGifts';

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
    final userId = FirebaseAuth.instance.currentUser.uid;
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
          title: Text('Requested gifts'),
        ),
        drawer: AppDrawer(),
        body: myRoom.roomies.length == 1
            ? Center(
                child: Text(
                  'You need to add a roomie to your room',
                  style: Theme.of(context).textTheme.headline6,
                ),
              )
            : Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.all(8.0),
                child: UserGiftContainer(userId, roomieId, yourUsername,
                    roomieUsername, myRoom.roomiesGift),
              ));
  }
}
