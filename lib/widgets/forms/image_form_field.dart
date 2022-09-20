import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageFormField extends StatefulWidget {
  final Function setImage;
  final String? initialValue;
  final bool? showImagePicker;
  final Function? deleteImage;

  const ImageFormField({
    Key? key,
    required this.setImage,
    this.initialValue,
    this.showImagePicker = true,
    this.deleteImage,
  }) : super(key: key);

  @override
  _ImageFormFieldState createState() => _ImageFormFieldState();
}

class _ImageFormFieldState extends State<ImageFormField> {
  File? _imageFile;
  String? _initialValue;
  final picker = ImagePicker();

  Future<void> _getImage(BuildContext context, ImageSource source) async {
    //final pickedFile = await picker.getImage(source: source, maxWidth: 400.0);
    final pickedFile = await picker.pickImage(source: source, maxWidth: 400);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _initialValue = null;
        widget.setImage(pickedFile);
        Navigator.pop(context);
      }
    });
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height:
                  (widget.initialValue != null && widget.deleteImage != null)
                      ? 210.0
                      : 170.0,
              padding: EdgeInsets.all(10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Image.Select',
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Divider(),
                    TextButton(
                        //textColor: Theme.of(context).primaryColor,
                        child: Text('Image.Camera'),
                        onPressed: () {
                          _getImage(context, ImageSource.camera);
                        }),
                    TextButton(
                        //textColor: Theme.of(context).primaryColor,
                        child: Text('Image.Gallery'),
                        onPressed: () {
                          _getImage(context, ImageSource.gallery);
                        }),
                    (widget.initialValue != null && widget.deleteImage != null)
                        ? TextButton(
                            //textColor: Theme.of(context).primaryColor,
                            child: Text('Image.Delete'),
                            onPressed: () {
                              widget.deleteImage!();
                            })
                        : Container(width: 0.0, height: 0.0)
                  ]));
        });
  }

  @override
  void initState() {
    _initialValue = widget.initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(ImageFormField oldWidget) {
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _initialValue = widget.initialValue;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (widget.showImagePicker != null) {
            if (widget.showImagePicker!) {
              _openImagePicker(context);
            }
          }
        },
        child: CircleAvatar(
            backgroundColor: Theme.of(context).backgroundColor,
            foregroundColor: Theme.of(context).primaryColor,
            radius: 40.0,
            child: ClipOval(
                child: _initialValue == null
                    ? (_imageFile == null
                        ? Icon(Icons.camera_alt)
                        : Image.file(_imageFile!,
                            fit: BoxFit.cover, height: 80.0, width: 80.0))
                    : Image.network(_initialValue!,
                        fit: BoxFit.cover, height: 80.0, width: 80.0))));
  }
}
