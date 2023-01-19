import 'dart:io'; // at beginning of file
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);
  final void Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker>
    with SingleTickerProviderStateMixin {
  File pickedImageFile;
  bool isLoading = false;
  AnimationController _animationController;
  Animation<double> _imageAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _imageAnimation = Tween(begin: 0.0, end: 1.0).animate(
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

  void _pickImage() async {
    final picker = ImagePicker();
    setState(() {
      isLoading = true;
    });
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 1,
    ); //maxWidth: 150

    if (pickedImage != null) {
      setState(() {
        pickedImageFile = File(pickedImage.path);
        isLoading = false;
      });
    }

    setState(() {
      isLoading = false;
    });
    widget.imagePickFn(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: !isLoading
            ? pickedImageFile != null
                ? CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey,
                    backgroundImage: Image(
                      image: FileImage(pickedImageFile),
                      opacity: _imageAnimation,
                    ).image,
                  )
                : const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey,
                  )
            : CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey,
                child: LoadingAnimationWidget.hexagonDots(
                    color: Colors.white, size: 20),
              ),
      ),
      Expanded(
        child: TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(
            Icons.image,
          ),
          label: Text(
            'Add image',
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
        ),
      ),
    ]);
  }
}
