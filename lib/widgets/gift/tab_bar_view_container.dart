import 'package:clean_mates_app/models/gift.dart';
import 'package:clean_mates_app/models/userGift.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class TabBarViewContainer extends StatefulWidget {
  final List<UserGift> yourBought;
  final List<UserGift> yourRecived;
  final String userId;
  final Function(String userId, int selectedIndex) recive;

  TabBarViewContainer(@required this.yourBought, @required this.yourRecived,
      @required this.recive, @required this.userId);

  @override
  State<TabBarViewContainer> createState() => _TabBarViewContainerState();
}

class _TabBarViewContainerState extends State<TabBarViewContainer>
    with SingleTickerProviderStateMixin {
  var _boughtExpanded = false;
  var _recivedExpanded = false;

  AnimationController _animationController;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    widget.yourRecived
        .sort(((a, b) => b.realizedDate.compareTo(a.realizedDate)));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.yourRecived
        .sort(((a, b) => b.realizedDate.compareTo(a.realizedDate)));
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            child: Text(
              widget.yourBought.length.toString(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).dividerColor,
          ),
          title: Text('Bought gifts'),
          trailing: IconButton(
            icon: Icon(_boughtExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                _boughtExpanded = !_boughtExpanded;
                _boughtExpanded
                    ? _animationController.forward()
                    : _animationController.reverse();
              });
            },
          ),
        ),

        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          height: _boughtExpanded
              ? min(
                  widget.yourBought.length * 30.0 + 70,
                  MediaQuery.of(context).size.height < 680.0
                      ? MediaQuery.of(context).size.height * 1 / 4
                      : MediaQuery.of(context).size.height * 1 / 3)
              : 0,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ListView.builder(
              itemCount: widget.yourBought.length,
              itemBuilder: ((context, index) => Dismissible(
                    key: Key(widget.yourBought[index].id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Theme.of(context).colorScheme.primary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Recive',
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 40,
                          ),
                        ],
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                    ),
                    onDismissed: (direction) {
                      widget.recive(widget.userId, index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.yourBought[index].giftName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          index == 0
                              ? Container(
                                  width: 180,
                                  height: 60,
                                  child: Lottie.asset(
                                    'assets/animations/lottie/swipe.json',
                                    height: 60,
                                    width: 90,
                                    fit: BoxFit.fitWidth,
                                  ),
                                )
                              : Container(
                                  height: 60,
                                ),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        ),

        Divider(),
        ListTile(
          title: Text('Recived gifts'),
          leading: CircleAvatar(
            child: Text(widget.yourRecived.length.toString(),
                style: TextStyle(color: Colors.white)),
            backgroundColor: Theme.of(context).dividerColor,
          ),
          trailing: IconButton(
            icon:
                Icon(_recivedExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                _recivedExpanded = !_recivedExpanded;
              });
            },
          ),
        ),
        //if (_recivedExpanded)
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          height: _recivedExpanded
              ? min(
                  widget.yourRecived.length * 30.0 + 50,
                  MediaQuery.of(context).size.height < 680.0
                      ? MediaQuery.of(context).size.height * 1 / 4
                      : MediaQuery.of(context).size.height * 1 / 3)
              : 0,
          child: ListView.builder(
            itemCount: widget.yourRecived.length,
            itemBuilder: ((context, index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.yourRecived[index].giftName,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd/MM hh:mm')
                            .format(widget.yourRecived[index].boughtDate),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ],
    );
  }
}
