import 'package:clean_mates_app/screens/gratification_gift_screen.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:rive/rive.dart';

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
  Function refreshGifts;
  BuyGiftContainer(
      @required this.gifts, @required this.userId, @required this.refreshGifts);

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

      Navigator.of(context).pushReplacementNamed(
          GratificationGiftScreen.routeName,
          arguments: selectedGifts.length);
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
          title: const Text('An error occured'),
          content: const Text("You don't have enought points"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Okay'),
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
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            child: AnimatedSwitcher(
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              duration: const Duration(milliseconds: 600),
              child: Text(
                '${giftsointsSum}',
                key: ValueKey<int>(giftsointsSum),
              ),
            ),
          ),
          Expanded(
            child: CustomRefreshIndicator(
              builder: MaterialIndicatorDelegate(
                builder: (context, controller) {
                  return const CircleAvatar(
                    radius: 55,
                    backgroundColor: Color.fromRGBO(47, 149, 153, 1),
                    child: RiveAnimation.asset(
                      'assets/animations/indicator.riv',
                    ),
                  );
                },
              ),
              onRefresh: () => widget.refreshGifts(),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                child: ListView.builder(
                  itemCount: widget.gifts.length,
                  itemBuilder: ((context, index) => Column(
                        children: [
                          CheckboxListTile(
                            title: Text(
                              widget.gifts[index].giftName,
                              style: TextStyle(
                                  fontWeight: selectedIndexes.contains(index)
                                      ? FontWeight.w500
                                      : FontWeight.normal),
                            ),
                            secondary: CircleAvatar(
                              radius: selectedIndexes.contains(index) ? 23 : 22,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: CircleAvatar(
                                radius: 20,
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                child: Text('${widget.gifts[index].points}',
                                    style: TextStyle(
                                        fontWeight:
                                            selectedIndexes.contains(index)
                                                ? FontWeight.bold
                                                : FontWeight.normal)),
                              ),
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
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                          Divider()
                        ],
                      )),
                ),
              ),
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
                : const Text('Save'),
          )
        ],
      ),
    );
  }
}
