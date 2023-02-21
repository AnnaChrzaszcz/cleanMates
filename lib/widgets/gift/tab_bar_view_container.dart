import 'dart:math';
import 'package:intl/intl.dart';
import 'package:clean_mates_app/models/userGift.dart';
import 'package:flutter/material.dart';

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
  var _boughtExpanded = true;
  var _recivedExpanded = false;

  AnimationController _animationController;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    widget.yourRecived
        .sort(((a, b) => b.realizedDate.compareTo(a.realizedDate)));
    super.initState();
    _animationController.forward();
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
        GestureDetector(
          onTap: () {
            setState(() {
              _boughtExpanded = !_boughtExpanded;
              _boughtExpanded
                  ? _animationController.forward()
                  : _animationController.reverse();
            });
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).dividerColor,
              child: Text(
                widget.yourBought.length.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: const Text('Requested gifts'),
            trailing:
                Icon(_boughtExpanded ? Icons.expand_less : Icons.expand_more),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
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
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
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
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          index == 0
                              ? SizedBox(
                                  width: 100,
                                  height: 60,
                                  child: Lottie.asset(
                                    'assets/animations/lottie/swipe2.json',
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
        const Divider(),
        GestureDetector(
          onTap: () {
            setState(() {
              _recivedExpanded = !_recivedExpanded;
            });
          },
          child: ListTile(
            title: const Text('Recived gifts'),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).dividerColor,
              child: Text(widget.yourRecived.length.toString(),
                  style: const TextStyle(color: Colors.white)),
            ),
            trailing:
                Icon(_recivedExpanded ? Icons.expand_less : Icons.expand_more),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.yourRecived[index].realizedDate != null
                            ? DateFormat('dd/MM HH:mm')
                                .format(widget.yourRecived[index].realizedDate)
                            : '',
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
