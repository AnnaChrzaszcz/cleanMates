import 'package:clean_mates_app/models/gift.dart';
import 'package:clean_mates_app/models/userGift.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';

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
  var yourSelectedIndex = -1;
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

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            child: Text(widget.yourBought.length.toString()),
            backgroundColor: Theme.of(context).dividerColor,
          ),
          title: Text('Bught gifts'),
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
              ? min(widget.yourBought.length * 30.0 + 50,
                  MediaQuery.of(context).size.height < 680.0 ? 100 : 140)
              : 0,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ListView.builder(
              itemCount: widget.yourBought.length,
              itemBuilder: ((context, index) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.yourBought[index].giftName,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Checkbox(
                            activeColor: Theme.of(context).primaryColor,
                            value: yourSelectedIndex == index,
                            onChanged: (value) {
                              setState(() {
                                yourSelectedIndex = value ? index : -1;
                              });
                            }),
                      ],
                    ),
                  )),
            ),
          ),
        ),
        if (_boughtExpanded)
          ElevatedButton(
            onPressed: yourSelectedIndex >= 0
                ? () {
                    widget.recive(widget.userId, yourSelectedIndex);
                  }
                : null,
            child: false ? CircularProgressIndicator() : Text('Receive'),
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
        Divider(),
        ListTile(
          title: Text('Recived gifts'),
          leading: CircleAvatar(
            child: Text(widget.yourRecived.length.toString()),
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
              ? min(widget.yourRecived.length * 30.0 + 50,
                  MediaQuery.of(context).size.height < 680.0 ? 100 : 140)
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
