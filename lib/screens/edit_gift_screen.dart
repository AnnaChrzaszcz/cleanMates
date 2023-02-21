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
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 30, bottom: 10),
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
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      icons[_iconSelectedIndex],
                                      size: 40,
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _nameEditingController,
                                        decoration: const InputDecoration(
                                            labelText: 'Gift name'),
                                        textInputAction: TextInputAction.done,
                                        onChanged: ((value) {
                                          setState(() {
                                            _iconSelectedIndex = 4;
                                          });
                                        }),
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
                                          if (value.isEmpty) {
                                            return 'enter a name';
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
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
                                                  ? const Color.fromRGBO(
                                                      242, 107, 56, 1)
                                                  : const Color.fromRGBO(
                                                      240, 240, 240, 1),
                                              padding: const EdgeInsets.all(15),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          )
                                        ],
                                      );
                                    })),
                              ),
                              TextFormField(
                                  controller: _pointsEditingController,
                                  decoration:
                                      const InputDecoration(labelText: 'Value'),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: ((_) => _saveForm()),
                                  keyboardType: TextInputType.number,
                                  focusNode: _pointsFocusNode,
                                  validator: (value) {
                                    if (value.isEmpty) return 'enter a price';
                                    if (int.parse(value) == null) {
                                      return 'enter a int value';
                                    } else if (int.parse(value) <= 0) {
                                      return 'price must be grater than 0';
                                    } else if (int.parse(value) > 1000) {
                                      return 'price can not be greater than 1000';
                                    } else {
                                      return null;
                                    }
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
                                  trackShape:
                                      const RoundedRectSliderTrackShape(),
                                  activeTrackColor:
                                      Theme.of(context).colorScheme.primary,
                                  inactiveTrackColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5),
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 14.0,
                                    pressedElevation: 8.0,
                                  ),
                                  thumbColor:
                                      const Color.fromRGBO(242, 107, 56, 1),
                                  overlayColor:
                                      const Color.fromRGBO(242, 107, 56, 0.2),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 32.0),
                                  tickMarkShape:
                                      const RoundSliderTickMarkShape(),
                                  activeTickMarkColor:
                                      const Color.fromRGBO(247, 219, 79, 1),
                                  inactiveTickMarkColor: Colors.white,
                                  valueIndicatorShape:
                                      const PaddleSliderValueIndicatorShape(),
                                  valueIndicatorColor:
                                      const Color.fromRGBO(242, 107, 56, 1),
                                  valueIndicatorTextStyle: const TextStyle(
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

                                                    _value -= 100;
                                                    _pointsEditingController
                                                            .text =
                                                        _value
                                                            .toInt()
                                                            .toString();
                                                  });
                                                }
                                              : null,
                                          icon: const Icon(
                                              Icons.arrow_back_ios_new)),
                                      const Text('- 100')
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
                                          icon: const Icon(
                                              Icons.arrow_forward_ios)),
                                      const Text('+ 100')
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      child: const Text('Save'),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
