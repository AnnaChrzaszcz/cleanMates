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

class _TabBarViewContainerState extends State<TabBarViewContainer> {
  var _boughtExpanded = false;
  var _recivedExpanded = false;
  var yourSelectedIndex = -1;

  @override
  void initState() {
    widget.yourRecived
        .sort(((a, b) => b.realizedDate.compareTo(a.realizedDate)));
    // TODO: implement initState
    super.initState();
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
              });
            },
          ),
        ),
        if (_boughtExpanded)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            height: min(
                widget.yourBought.length * 30.0 + 50,
                MediaQuery.of(context).size.height < 680.0
                    ? MediaQuery.of(context).size.height * 1 / 4
                    : MediaQuery.of(context).size.height * 1 / 3),
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
        if (_boughtExpanded)
          ElevatedButton(
            onPressed: yourSelectedIndex >= 0
                ? () {
                    widget.recive(widget.userId, yourSelectedIndex);
                    setState(() {
                      yourSelectedIndex = -1;
                    });
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
        if (_recivedExpanded)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            height: min(
                widget.yourRecived.length * 30.0 + 50,
                MediaQuery.of(context).size.height < 680.0
                    ? MediaQuery.of(context).size.height * 1 / 4
                    : MediaQuery.of(context).size.height * 1 / 3),
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
