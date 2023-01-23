import 'package:clean_mates_app/providers/gifts_provider.dart';
import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EditGiftScreen extends StatefulWidget {
  static const routeName = '/editGift';

  final String roomId;

  EditGiftScreen({this.roomId});

  @override
  _EditGiftScreenState createState() => _EditGiftScreenState();
}

class _EditGiftScreenState extends State<EditGiftScreen> {
  final _form = GlobalKey<FormState>();
  var _initValues = {'roomName': '', 'points': ''};
  final _pointsFocusNode = FocusNode();
  TextEditingController _pointsEditingController;
  TextEditingController _nameEditingController;
  var _isInit = true;
  var _isLoading = false;
  String roomId;
  var _editedGift = Gift(
      id: null,
      giftName: '',
      points: 0,
      iconCode: Icons.card_giftcard_outlined.codePoint);
  double _value = 0;
  List<Map> dictionary = [
    {'name': 'Treat', 'index': 5},
    {'name': 'Massage', 'index': 6},
    {'name': 'Cinema tickets', 'index': 7},
    {'name': 'Breakfast to bed', 'index': 0},
    {'name': 'Day off cleaning', 'index': 2},
  ];
  int _selectedDictionaryIndex = -1;
  double min;
  double max;
  var dziesiatek;
  var appBarName = 'Create new gift';
  List<IconData> icons = [
    Icons.bed,
    Icons.food_bank_rounded,
    Icons.mood,
    Icons.coffee,
    Icons.card_giftcard_outlined,
    Icons.cookie,
    Icons.spa_outlined,
    Icons.theaters,
    Icons.wine_bar
  ];
  var _iconSelectedIndex = 4;

  Future<void> _saveForm() async {
    final formValid = _form.currentState.validate();
    if (formValid) {
      setState(() {
        _isLoading = true;
      });
      print(_editedGift.iconCode);
      _form.currentState.save();
      if (_editedGift.id != null) {
        await Provider.of<GiftsProvider>(context, listen: false)
            .updateGift(_editedGift.id, _editedGift);
      } else {
        try {
          await Provider.of<GiftsProvider>(context, listen: false)
              .addGift(_editedGift, roomId);
        } catch (err) {
          print(err);
        }
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      if (routeArgs == null) {
        roomId = widget.roomId;
      } else {
        final id = routeArgs['id'];
        roomId = routeArgs['roomId'];
        if (id != null) {
          _editedGift =
              Provider.of<GiftsProvider>(context, listen: false).findById(id);
          _initValues = {
            'giftName': _editedGift.giftName,
            'points': _editedGift.points.toString(),
          };
          appBarName = 'Edit gift';
          _iconSelectedIndex = icons
              .indexWhere((icon) => icon.codePoint == _editedGift.iconCode);
          dziesiatek = (_editedGift.points / 100).toInt();
          min = dziesiatek * 100.toDouble();
          max = (dziesiatek + 1) * 100.toDouble();
          _value = _editedGift.points.toDouble();
          _pointsEditingController.text = _initValues['points'];
          _nameEditingController.text = _initValues['giftName'];
        }
      }
    }
    _isInit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _pointsEditingController = TextEditingController();
    _nameEditingController = TextEditingController();
    min = 0.0;
    max = 100.0;
    dziesiatek = 0;
    super.initState();
  }

  @override
  void dispose() {
    _pointsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
        // actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 30, bottom: 10),
              // decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
              child: Column(
                children: [
                  Form(
                    key: _form,
                    child: Expanded(
                      child: Container(
                        child: ListView(children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: double.infinity,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      icons[_iconSelectedIndex],
                                      size: 40,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _nameEditingController,
                                        decoration: InputDecoration(
                                            labelText: 'Gift name'),
                                        textInputAction: TextInputAction.done,
                                        // onFieldSubmitted: (_) => FocusScope.of(context)
                                        //     .requestFocus(_pointsFocusNode),
                                        onSaved: (value) {
                                          _editedGift = Gift(
                                              id: _editedGift.id,
                                              giftName: value,
                                              points: _editedGift.points,
                                              iconCode:
                                                  icons[_iconSelectedIndex]
                                                      .codePoint);
                                        },
                                        validator: (value) {
                                          if (value.isEmpty)
                                            return 'enter a name';
                                          else
                                            return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 80,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: dictionary.length,
                                    itemBuilder: ((context, index) {
                                      return Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (index ==
                                                    _selectedDictionaryIndex) {
                                                  _nameEditingController.text =
                                                      '';
                                                  _selectedDictionaryIndex = 4;
                                                } else {
                                                  _nameEditingController.text =
                                                      dictionary[index]['name'];
                                                  _selectedDictionaryIndex =
                                                      index;
                                                  _iconSelectedIndex =
                                                      dictionary[index]
                                                          ['index'];
                                                }
                                              });
                                            },
                                            child: Chip(
                                              label: Text(
                                                  '${dictionary[index]['name']}',
                                                  style: TextStyle(
                                                      color: index ==
                                                              _selectedDictionaryIndex
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontWeight: index ==
                                                              _selectedDictionaryIndex
                                                          ? FontWeight.bold
                                                          : FontWeight.normal)),
                                              backgroundColor: index ==
                                                      _selectedDictionaryIndex
                                                  ? Color.fromRGBO(
                                                      242, 107, 56, 1)
                                                  : Color.fromRGBO(
                                                      240, 240, 240, 1),
                                              padding: EdgeInsets.all(15),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          )
                                        ],
                                      );
                                    })),
                              ),
                              TextFormField(
                                  controller: _pointsEditingController,
                                  decoration:
                                      InputDecoration(labelText: 'Value'),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: ((_) => _saveForm()),
                                  keyboardType: TextInputType.number,
                                  focusNode: _pointsFocusNode,
                                  validator: (value) {
                                    if (value.isEmpty) return 'enter a price';
                                    if (int.parse(value) == null)
                                      return 'enter a int value';
                                    else if (int.parse(value) <= 0) {
                                      return 'price must be grater than 0';
                                    } else if (int.parse(value) > 1000) {
                                      return 'price can not be greater than 1000';
                                    } else
                                      return null;
                                  },
                                  onSaved: (value) {
                                    _editedGift = Gift(
                                        id: _editedGift.id,
                                        giftName: _editedGift.giftName,
                                        points: int.parse(value),
                                        iconCode: icons[_iconSelectedIndex]
                                            .codePoint);
                                  }),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 10.0,
                                  trackShape: RoundedRectSliderTrackShape(),
                                  activeTrackColor:
                                      Theme.of(context).colorScheme.primary,
                                  inactiveTrackColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5),
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 14.0,
                                    pressedElevation: 8.0,
                                  ),
                                  thumbColor: Color.fromRGBO(242, 107, 56, 1),
                                  overlayColor:
                                      Color.fromRGBO(242, 107, 56, 0.2),
                                  overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 32.0),
                                  tickMarkShape: RoundSliderTickMarkShape(),
                                  activeTickMarkColor:
                                      Color.fromRGBO(247, 219, 79, 1),
                                  inactiveTickMarkColor: Colors.white,
                                  valueIndicatorShape:
                                      PaddleSliderValueIndicatorShape(),
                                  valueIndicatorColor:
                                      Color.fromRGBO(242, 107, 56, 1),
                                  valueIndicatorTextStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                                child: Slider(
                                  min: min,
                                  max: max,
                                  value: _value,
                                  divisions: 10,
                                  label: '${_value.round()}',
                                  onChanged: (value) {
                                    setState(() {
                                      _value = value;
                                      _pointsEditingController.text =
                                          _value.toInt().toString();
                                    });
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: min != 0.0
                                              ? () {
                                                  setState(() {
                                                    dziesiatek -= 1;
                                                    max = (dziesiatek + 1) *
                                                        100.toDouble();

                                                    min = (dziesiatek) *
                                                        100.toDouble();
                                                    // min = 0.0;
                                                    // max = 100.0;
                                                    _value -= 100;
                                                    _pointsEditingController
                                                            .text =
                                                        _value
                                                            .toInt()
                                                            .toString();
                                                  });
                                                }
                                              : null,
                                          icon: Icon(Icons.arrow_back_ios_new)),
                                      Text('- 100')
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: max == 1000
                                              ? null
                                              : () {
                                                  setState(() {
                                                    dziesiatek += 1;
                                                    min = dziesiatek *
                                                        100.toDouble();

                                                    max = (dziesiatek + 1) *
                                                        100.toDouble();

                                                    _value += 100;

                                                    _pointsEditingController
                                                            .text =
                                                        _value
                                                            .toInt()
                                                            .toString();
                                                  });
                                                },
                                          icon: Icon(Icons.arrow_forward_ios)),
                                      Text('+ 100')
                                    ],
                                  )
                                ],
                              ),
                              // Container(
                              //   child: CarouselSlider.builder(
                              //     key: _scaffoldKey,
                              //     options: CarouselOptions(
                              //       height: 100,
                              //       viewportFraction: 0.4,
                              //       initialPage: _iconSelectedIndex,
                              //       enableInfiniteScroll: false,
                              //       reverse: false,
                              //       enlargeCenterPage: true,
                              //       onPageChanged: (index, reason) {
                              //         setState(() {
                              //           _iconSelectedIndex = index;
                              //           _editedGift = Gift(
                              //             id: _editedGift.id,
                              //             giftName: _editedGift.giftName,
                              //             points: _editedGift.points,
                              //             iconCode: icons[_iconSelectedIndex]
                              //                 .codePoint,
                              //           );
                              //         });
                              //         print(_editedGift.iconCode);
                              //       },
                              //       enlargeStrategy:
                              //           CenterPageEnlargeStrategy.height,
                              //       enlargeFactor: 5,
                              //       scrollDirection: Axis.horizontal,
                              //     ),
                              //     itemCount: icons.length,
                              //     itemBuilder: (BuildContext context,
                              //             int itemIndex, int pageViewIndex) =>
                              //         Icon(
                              //       icons[itemIndex],
                              //       color: itemIndex == _iconSelectedIndex
                              //           ? Color.fromRGBO(242, 107, 56, 1)
                              //           : Theme.of(context).colorScheme.primary,
                              //       size: itemIndex == _iconSelectedIndex
                              //           ? 55
                              //           : 35,
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ]),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      child: Text('Save'),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
