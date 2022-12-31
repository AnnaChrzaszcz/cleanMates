import 'package:clean_mates_app/providers/gifts_provider.dart';
import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'package:provider/provider.dart';

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
  var _isInit = true;
  var _isLoading = false;
  String roomId;
  var _editedGift = Gift(
    id: null,
    giftName: '',
    points: 0,
  );

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
          print(_initValues);
        }
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
        title: Text('New gift'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Form(
                      key: _form,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ListView(
                          children: [
                            TextFormField(
                              initialValue: _initValues['giftName'],
                              decoration:
                                  InputDecoration(labelText: 'Gift name'),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_pointsFocusNode),
                              onSaved: (value) {
                                _editedGift = Gift(
                                  id: _editedGift.id,
                                  giftName: value,
                                  points: _editedGift.points,
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
                                  } else
                                    return null;
                                },
                                onSaved: (value) {
                                  _editedGift = Gift(
                                      id: _editedGift.id,
                                      giftName: _editedGift.giftName,
                                      points: int.parse(value));
                                }),
                          ],
                        ),
                      )),
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
