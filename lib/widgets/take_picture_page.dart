import 'package:camera/camera.dart';
import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/assets.dart';
import 'package:fight_blight_bmore/constants/enums.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/models/asset_file/asset_file.dart';
import 'package:fight_blight_bmore/widgets/video_timer.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_compress/video_compress.dart';

class TakePicturePage extends StatefulWidget {
  final CameraDescription camera;
  final int selectedIndex;

  TakePicturePage({required this.camera, required this.selectedIndex});

  @override
  _TakePicturePageState createState() => _TakePicturePageState();
}

class _TakePicturePageState extends State<TakePicturePage> {
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  var vidPath;
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;
  VideoProcess videoProcess = VideoProcess.none;
  int recordingTime = 0;

  @override
  initState() {
    super.initState();
    _cameraController = CameraController(widget.camera, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.yuv420);
    _initializeCameraControllerFuture = _cameraController.initialize();
  }

  void _takePicture(BuildContext context) async {
    try {
      await _initializeCameraControllerFuture;
      if (widget.selectedIndex == 0) {
        var img = await _cameraController.takePicture();
        var file = AssetFile(
            id: UniqueKey().toString(), path: img.path, type: AssetType.image);
        Navigator.pop(context, file);
      } else {
        if (videoProcess == VideoProcess.none) {
          await _cameraController.startVideoRecording();
          setState(() {
            videoProcess = VideoProcess.start;
          });
        } else {
          await _stopVideo();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _playPause(BuildContext context) async {
    try {
      await _initializeCameraControllerFuture;
      if (videoProcess == VideoProcess.start ||
          videoProcess == VideoProcess.resume) {
        await _cameraController.pauseVideoRecording();
        setState(() {
          videoProcess = VideoProcess.pause;
        });
      } else if (videoProcess == VideoProcess.pause) {
        await _cameraController.resumeVideoRecording();
        setState(() {
          videoProcess = VideoProcess.resume;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopVideo() async {
    var vid = await _cameraController.stopVideoRecording();
    setState(() {
      videoProcess = VideoProcess.none;
    });
    await VideoCompress.compressVideo(
      vid.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    ).then((mediaInfo) {
      var file = AssetFile(
          id: UniqueKey().toString(),
          path: mediaInfo!.path,
          type: AssetType.video);
      Navigator.pop(context, file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                Visibility(
                  visible: videoProcess == VideoProcess.start ||
                      videoProcess == VideoProcess.resume,
                  child: Padding(
                    padding: EdgeInsets.only(top: 45, bottom: 10),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        height: 40,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Color(0xFFEE4400),
                        ),
                        child: VideoTimer(
                          beginTime: recordingTime,
                          onChanged: (value) {
                            recordingTime = value;
                            print(recordingTime);
                            if (recordingTime == 120) {
                              _stopVideo();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, right: 10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      child: Text(
                        Strings.cancel,
                        style: normalTextStyle(
                          16,
                          fontFamily: FontFamily.sfProDisplay,
                          color: AppTheme.light().yellowColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
            FutureBuilder(
              future: _initializeCameraControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Expanded(
                    child: AspectRatio(
                        aspectRatio: 1.2,
                        child: CameraPreview(_cameraController)),
                  );
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    backgroundColor: AppTheme.light().primaryColor,
                  ));
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                widget.selectedIndex == 0 ? Strings.photo : Strings.video,
                style: normalTextStyle(
                  12,
                  fontFamily: FontFamily.sfProDisplay,
                  color: AppTheme.light().yellowColor,
                ),
              ),
            ),
            Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.only(bottom: 8.0, left: 20),
                    child: FloatingActionButton(
                      heroTag: 2,
                      onPressed: () {
                        _playPause(context);
                      },
                      backgroundColor: Colors.transparent,
                      child: getPauseIcon(),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: FloatingActionButton(
                      heroTag: 1,
                      onPressed: () {
                        _takePicture(context);
                      },
                      backgroundColor: Colors.transparent,
                      child: getIcon(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget getIcon() {
    if (widget.selectedIndex == 0) {
      return Image.asset(
        Assets.take_photo,
        width: 60,
      );
    } else {
      switch (videoProcess) {
        case VideoProcess.none:
          return Image.asset(
            Assets.take_video,
            width: 60,
          );
        case VideoProcess.start:
        case VideoProcess.pause:
        case VideoProcess.resume:
          return Image.asset(
            Assets.stop_video,
            width: 60,
          );
        case VideoProcess.stop:
          return Image.asset(
            Assets.take_video,
            width: 60,
          );
      }
    }
    return Container();
  }

  Widget getPauseIcon() {
    switch (videoProcess) {
      case VideoProcess.start:
      case VideoProcess.resume:
        return Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              border: Border.all(
                color: Colors.white,
                width: 4.0,
              ),
            ),
            child: Icon(
              Icons.pause,
              color: Colors.red,
              size: 40,
            ));
      case VideoProcess.pause:
        return Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            border: Border.all(
              color: Colors.white,
              width: 4.0,
            ),
          ),
          child: Image.asset(
            Assets.resume,
            color: Colors.red,
            width: 32,
          ),
        );
    }
    return Container();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
