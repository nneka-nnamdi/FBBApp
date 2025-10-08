import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fight_blight_bmore/widgets/take_picture_page.dart';

class LaunchScreen extends StatefulWidget {
  final int selectedIndex;

  LaunchScreen(this.selectedIndex);

  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  List<String> attachmentList = [];

  _launchCamera() {
    _showCamera();
  }

  _showCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    final pickedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePicturePage(
                  camera: camera,
                  selectedIndex: widget.selectedIndex,
                )));
    Navigator.pop(context, pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              child: GestureDetector(
                onTap: _launchCamera(),
                child: Card(
                  elevation: 10,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(),
                  child: Icon(
                    Icons.camera_front,
                    size: 10,
                  ),
                ),
              ),
            ),
            // attachmentList.length >= 1
            //     ? Padding(
            //   padding: const EdgeInsets.all(10),
            //   child: FileListPreview(attachmentList, _removeImage),
            // )
            //     : SizedBox(),
          ],
        ),
      ),
    );
  }
}
