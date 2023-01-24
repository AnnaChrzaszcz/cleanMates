import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/room.dart';
import '../providers/activities_provider.dart';
import 'package:provider/provider.dart';

class EditActivityScreen extends StatefulWidget {
  static const routeName = '/editActivity';

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
  List<String> dictionary = [
    'Cooking',
    'Washing dishes',
    'Washing windows',
    'Vacuuming',
    'Morning coffee'
  ];
  int _selectedDictionaryIndex = -1;

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

        _pointsEditingController.text = _initValues['points'];
        _nameEditingController.text = _initValues['activityName'];
        appBarName = 'Edit activity';
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
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.pink)),
                        child: ListView(children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                  _selectedDictionaryIndex = -1;
                                                } else {
                                                  _nameEditingController.text =
                                                      dictionary[index];
                                                  _selectedDictionaryIndex =
                                                      index;
                                                }
                                              });
                                            },
                                            child: Chip(
                                              label: Text(
                                                  '${dictionary[index]}',
                                                  style: TextStyle(
                                                      fontWeight: index ==
                                                              _selectedDictionaryIndex
                                                          ? FontWeight.bold
                                                          : FontWeight.normal)),
                                              backgroundColor: Color.fromRGBO(
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
                                      InputDecoration(labelText: 'Points'),
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
                                        activityName:
                                            _editedActivity.activityName,
                                        points: int.parse(value));
                                  }),
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
