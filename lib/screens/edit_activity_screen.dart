import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/room.dart';
import '../providers/activities_provider.dart';
import 'package:provider/provider.dart';

class EditActivityScreen extends StatefulWidget {
  static const routeName = '/editActivity';

  final String roomId;

  EditActivityScreen({this.roomId});

  @override
  _CreateNewActivityScreenState createState() =>
      _CreateNewActivityScreenState();
}

class _CreateNewActivityScreenState extends State<EditActivityScreen> {
  final _form = GlobalKey<FormState>();
  var _initValues = {'activityName': '', 'points': ''};
  final _pointsFocusNode = FocusNode();
  TextEditingController _pointsEditingController;
  TextEditingController _nameEditingController;
  var _isInit = true;
  var _isLoading = false;
  String roomId;
  var _editedActivity = Activity(
    id: null,
    activityName: '',
    points: 0,
  );
  double _value = 0;
  List<String> dictionary = [
    'Cooking',
    'Washing dishes',
    'Washing windows',
    'Vacuuming',
    'Morning coffee'
  ];
  int _selectedDictionaryIndex = -1;
  // double min = 0.0;
  // double max = 100.0;
  // var dziesiatek = 1;
  double min;
  double max;
  var dziesiatek;
  var appBarName = 'Create new activity';

  Future<void> _saveForm() async {
    final formValid = _form.currentState.validate();
    if (formValid) {
      setState(() {
        _isLoading = true;
      });
      _form.currentState.save();
      if (_editedActivity.id != null) {
        await Provider.of<ActivitiesProvider>(context, listen: false)
            .updateActivity(_editedActivity.id, _editedActivity);
      } else {
        try {
          await Provider.of<ActivitiesProvider>(context, listen: false)
              .addActivity(_editedActivity, roomId);
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
          _editedActivity =
              Provider.of<ActivitiesProvider>(context, listen: false)
                  .findById(id);
          _initValues = {
            'activityName': _editedActivity.activityName,
            'points': _editedActivity.points.toString(),
          };
          dziesiatek = (_editedActivity.points / 100).toInt();
          min = dziesiatek * 100.toDouble();
          max = (dziesiatek + 1) * 100.toDouble();
          _value = _editedActivity.points.toDouble();
          _pointsEditingController.text = _initValues['points'];
          _nameEditingController.text = _initValues['activityName'];
          appBarName = 'Edit activity';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
        //actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Form(
                    key: _form,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 30),
                      child: ListView(
                        children: [
                          TextFormField(
                            controller: _nameEditingController,
                            decoration:
                                InputDecoration(labelText: 'Activity name'),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_pointsFocusNode),
                            onSaved: (value) {
                              _editedActivity = Activity(
                                id: _editedActivity.id,
                                activityName: value,
                                points: _editedActivity.points,
                              );
                            },
                            validator: (value) {
                              if (value.isEmpty)
                                return 'enter a name';
                              else
                                return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
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
                                              _nameEditingController.text = '';
                                              _selectedDictionaryIndex = -1;
                                            } else {
                                              _nameEditingController.text =
                                                  dictionary[index];
                                              _selectedDictionaryIndex = index;
                                            }
                                          });
                                        },
                                        child: Chip(
                                          label: Text('${dictionary[index]}',
                                              style: TextStyle(
                                                  fontWeight: index ==
                                                          _selectedDictionaryIndex
                                                      ? FontWeight.bold
                                                      : FontWeight.normal)),
                                          backgroundColor:
                                              Color.fromRGBO(240, 240, 240, 1),
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
                          SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                              controller: _pointsEditingController,
                              decoration: InputDecoration(labelText: 'Points'),
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
                                } else if (int.parse(value) > 400) {
                                  return 'price can not be greater than 400';
                                } else
                                  return null;
                              },
                              onSaved: (value) {
                                _editedActivity = Activity(
                                    id: _editedActivity.id,
                                    activityName: _editedActivity.activityName,
                                    points: int.parse(value));
                              }),
                          SizedBox(
                            height: 30,
                          ),
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
                              overlayColor: Color.fromRGBO(242, 107, 56, 0.2),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 32.0),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                _pointsEditingController.text =
                                                    _value.toInt().toString();
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
                                      onPressed: max == 400
                                          ? null
                                          : () {
                                              setState(() {
                                                dziesiatek += 1;
                                                min =
                                                    dziesiatek * 100.toDouble();

                                                max = (dziesiatek + 1) *
                                                    100.toDouble();

                                                _value += 100;

                                                _pointsEditingController.text =
                                                    _value.toInt().toString();
                                              });
                                            },
                                      icon: Icon(Icons.arrow_forward_ios)),
                                  Text('+ 100')
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
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
    );
  }
}
