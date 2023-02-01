import 'package:clean_mates_app/providers/gifts_provider.dart';
import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EditGiftScreen extends StatefulWidget {
  static const routeName = '/editGift';

  @override
  _EditGiftScreenState createState() => _EditGiftScreenState();
}

class _EditGiftScreenState extends State<EditGiftScreen> {
  final _form = GlobalKey<FormState>();
  Map<String, dynamic> _initValues = {'roomName': '', 'points': ''};
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

  List<Map> dictionary = [
    {'name': 'Treat', 'index': 5},
    {'name': 'Massage', 'index': 6},
    {'name': 'Cinema tickets', 'index': 7},
    {'name': 'Breakfast to bed', 'index': 0},
    {'name': 'Day off cleaning', 'index': 2},
  ];
  int _selectedDictionaryIndex = -1;

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
    Icons.wine_bar,
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
        _iconSelectedIndex =
            icons.indexWhere((icon) => icon.codePoint == _editedGift.iconCode);
        _pointsEditingController.text = _initValues['points'];
        _nameEditingController.text = _initValues['giftName'];
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
    _nameEditingController.addListener(() {});
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
        //actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
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
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) =>
                                            FocusScope.of(context)
                                                .requestFocus(_pointsFocusNode),
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
                            ],
                          ),
                        ]),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 30),
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
