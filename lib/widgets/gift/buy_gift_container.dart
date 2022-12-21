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
  BuyGiftContainer(@required this.gifts, @required this.userId);

  @override
  _BuyGiftsContainerState createState() => _BuyGiftsContainerState();
}

class _BuyGiftsContainerState extends State<BuyGiftContainer> {
  var selectedIndexes = [];
  var giftsointsSum = 0;
  var _isLoading = false;

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
    return Expanded(
      child: Column(
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: widget.gifts.length,
                itemBuilder: ((context, index) => Column(
                      children: [
                        CheckboxListTile(
                          title: Text(
                            widget.gifts[index].giftName,
                            style: TextStyle(),
                          ),
                          secondary: CircleAvatar(
                            radius: 20,
                            backgroundColor: selectedIndexes.contains(index)
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor,
                            foregroundColor: Colors.white,
                            child: Text('${widget.gifts[index].points}'),
                          ),
                          value: selectedIndexes.contains(index),
                          onChanged: (_) {
                            if (selectedIndexes.contains(index)) {
                              setState(() {
                                selectedIndexes.remove(index);
                                giftsointsSum -= widget.gifts[index].points;
                              });
                            } else {
                              setState(() {
                                selectedIndexes.add(index);
                                giftsointsSum += widget.gifts[index].points;
                              });
                            }
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        Divider()
                      ],
                    )),
              ),
            ),
          ),
          if (selectedIndexes.length > 0)
            ElevatedButton(
              onPressed: selectedIndexes.length <= 0 ? null : () => _buyGifts(),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Buy (${giftsointsSum} points)'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled))
                      return Colors.grey;
                    return Theme.of(context)
                        .primaryColor; // Use the component's default.
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
