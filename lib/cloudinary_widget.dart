library cloudinary_widget;

import 'dart:convert';

import 'widgets/dash_painter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A Calculator.
class CloundinaryWidget extends StatefulWidget {
  // builds a widge that helps you upload images to cloudinary using
  //your upload_preset and clould name from your profile

  CloundinaryWidget({
    Key key,
    @required this.cloudName,
    @required this.uploadPreset,
    @required this.onChanged(String value),
    this.height = 200,
    this.borderColor,
    this.textStyle,
  }) : super(key: key);

  // Cloud name gotten from your cloudinary
  final String cloudName;

  // Upload preset also gotten from you cloudinary
  final String uploadPreset;

  // The on changed function returns the uploaded image's url as a String.
  final Function onChanged;

  // heights defines the length of the widget and it is set to 200px by defualt
  final double height;

  // Colors for the bother
  final Color borderColor;

  //
  final TextStyle textStyle;
  @override
  _CloundinaryWidgetState createState() => _CloundinaryWidgetState();
}

class _CloundinaryWidgetState extends State<CloundinaryWidget> {
  var imageUrl;
  final picker = ImagePicker();
  bool isloading = false;
  Future _imgFromGallery() async {
    var url = "https://api.cloudinary.com/v1_1/${widget.cloudName}/upload";
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      isloading = true;
    });

    Dio dio = Dio();
    FormData formData = new FormData.fromMap({
      "file": await MultipartFile.fromFile(
        pickedFile.path,
      ),
      "upload_preset": widget.uploadPreset,
      "cloud_name": widget.cloudName,
    });
    try {
      Response response = await dio.post(url, data: formData);

      var data = jsonDecode(response.toString());

      setState(() {
        isloading = false;
        imageUrl = data['secure_url'];
        widget.onChanged(imageUrl);
      });
    } catch (e) {
      print(e);
    }
  }

  Future _imgFromCamera() async {
    var url = "https://api.cloudinary.com/v1_1/${widget.cloudName}/upload";
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    setState(() {
      isloading = true;
    });

    Dio dio = Dio();
    FormData formData = new FormData.fromMap({
      "file": await MultipartFile.fromFile(
        pickedFile.path,
      ),
      "upload_preset": "cyuket",
      "cloud_name": "cyuket",
    });
    try {
      Response response = await dio.post(url, data: formData);

      var data = jsonDecode(response.toString());

      setState(() {
        isloading = false;
        imageUrl = data['secure_url'];
        widget.onChanged(imageUrl);
      });
    } catch (e) {
      print(e);
    }
  }

  void _showPicker(context) {
    Scaffold.of(context).showBottomSheet((context) => SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      child: Container(
        height: widget.height,
        width: double.infinity,
        child: CustomPaint(
          painter: DashRectPainter(
            strokeWidth: 2,
            color: widget.borderColor == null
                ? Color(0xff7DA4BC)
                : widget.borderColor,
            gap: 5,
          ),
          child: imageUrl == null
              ? !isloading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          color: widget.borderColor == null
                              ? Color(0xff7DA4BC)
                              : widget.borderColor,
                          size: 40,
                        ),
                        Text(
                          "+ Upload any image",
                          style: widget.textStyle != null
                              ? widget.textStyle
                              : TextStyle(
                                  color: Color(0xff7DA4BC),
                                  fontSize: 20,
                                ),
                        ),
                      ],
                    )
                  : Center(child: CircularProgressIndicator())
              : Center(
                  child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        image: imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover)
                            : null,
                      )),
                ),
        ),
      ),
    );
  }
}
