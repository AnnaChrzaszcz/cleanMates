import 'user_gift_container.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../../models/exceptions/logistic_expection.dart';
import 'package:clean_mates_app/models/gift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/activity.dart';
import '../../providers/rooms_provider.dart';
import 'package:provider/provider.dart';

class BuyGiftContainer extends StatefulWidget {
  final List<Gift> gifts;
  final String userId;
  final int yourPoints;
  BuyGiftContainer(
      @required this.gifts, @required this.userId, @required this.yourPoints);

  @override
  _BuyGiftsContainerState createState() => _BuyGiftsContainerState();
}

class _BuyGiftsContainerState extends State<BuyGiftContainer> {
  var selectedIndexes = [];
  var giftsointsSum = 0;
  var _isLoading = false;
  var actualUserPoints;

  void _buyGifts() async {
    setState(() {
      _isLoading = true;
    });
    List<Gift> selectedGifts = [];
    selectedIndexes.forEach((index) {
      selectedGifts.add(widget.gifts[index]);
    });
    try {
      await Provider.of<RoomsProvider>(context, listen: false).addGiftsToRoomie(
          selectedGifts, widget.userId, widget.gifts[0].roomId, giftsointsSum);
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You bought ${selectedGifts.length} gifts'),
          duration: const Duration(seconds: 2),
        ),
      );
    } on LogisticExpection catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occured'),
          content: Text("You don't have enought points"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Okay'),
            )
          ],
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              child: FittedBox(
                child: Text(
                  '${giftsointsSum} / ${widget.yourPoints}',
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              child: ListView.builder(
                  itemCount: widget.gifts.length,
                  itemBuilder: ((context, index) => Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 20,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor:
                                        Theme.of(context).dividerColor,
                                    foregroundColor: Colors.white,
                                    child: Icon(
                                      IconData((widget.gifts[index].iconCode),
                                          fontFamily: 'MaterialIcons'),
                                      size: 35,
                                    )),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      widget.gifts[index].giftName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                    Text('${widget.gifts[index].points} pts',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: Colors.black,
                                        child: FittedBox(
                                          child: IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              setState(() {
                                                selectedIndexes.add(index);
                                                giftsointsSum +=
                                                    widget.gifts[index].points;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        '${selectedIndexes.where((el) => el == index).toList().length}',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: Colors.black,
                                        child: IconButton(
                                          icon: Icon(Icons.remove),
                                          onPressed: () {
                                            setState(() {
                                              var indextoDelete =
                                                  selectedIndexes.indexWhere(
                                                      (ind) => ind == index);

                                              if (indextoDelete != -1) {
                                                selectedIndexes
                                                    .removeAt(indextoDelete);
                                                giftsointsSum -=
                                                    widget.gifts[index].points;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ))),
            ),
          ),
          ElevatedButton(
            onPressed: selectedIndexes.isEmpty ? null : () => _buyGifts(),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled))
                    return Colors.grey;
                  return Theme.of(context)
                      .colorScheme
                      .primary; // Use the component's default.
                },
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Buy'),
          )
        ],
      ),
    );
  }
}
