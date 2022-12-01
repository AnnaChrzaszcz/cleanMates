import 'dart:io'; // at beginning of file
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);
  final void Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File pickedImageFile;
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 1,
    ); //maxWidth: 150
    setState(() {
      pickedImageFile = File(pickedImage.path);
    });
    widget.imagePickFn(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey,
        backgroundImage:
            pickedImageFile != null ? FileImage(pickedImageFile) : null,
      ),
      TextButton.icon(
        onPressed: _pickImage,
        icon: Icon(
          Icons.image,
        ),
        label: Text(
          'Add image',
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
      ),
    ]);
  }
}
