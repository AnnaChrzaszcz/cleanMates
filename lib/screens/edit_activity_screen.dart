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
  var _isInit = true;
  var _isLoading = false;
  String roomId;
  var _editedActivity = Activity(
    id: null,
    activityName: '',
    points: 0,
  );

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
        print(_initValues);
      }
    }
    _isInit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
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
        title: Text('Edit Activity'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['activityName'],
                      decoration: InputDecoration(labelText: 'Activity name'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_pointsFocusNode),
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
                    TextFormField(
                        initialValue: _initValues['points'],
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
                          } else
                            return null;
                        },
                        onSaved: (value) {
                          _editedActivity = Activity(
                              id: _editedActivity.id,
                              activityName: _editedActivity.activityName,
                              points: int.parse(value));
                        }),
                  ],
                ),
              )),
    );
  }
}
