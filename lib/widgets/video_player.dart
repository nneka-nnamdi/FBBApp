import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key, required this.pathUrl}) : super(key: key);

  final String pathUrl;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    print(widget.pathUrl);
    _controller = VideoPlayerController.network(
      widget.pathUrl,
    );

    _initializeVideoPlayerFuture = _controller.initialize();

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _controller.play();
            print(_controller.value.duration);
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            // return Container(
            //   alignment: Alignment.center,
            //   child: Center(
            //     child: Column(children: [
            return Center(
              child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: Stack(
                    children: [
                      VideoPlayer(_controller),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: false,
                          colors: VideoProgressColors(
                            playedColor: AppTheme.light().primaryColor,
                          ),
                          padding: EdgeInsets.only(bottom: 10.0),
                        ),
                      ),
                    ],
                  )),
            ); //,
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Wrap the play or pause in a call to `setState`. This ensures the
      //     // correct icon is shown.
      //     setState(() {
      //       // If the video is playing, pause it.
      //       if (_controller.value.isPlaying) {
      //         _controller.pause();
      //       } else {
      //         // If the video is paused, play it.
      //         _controller.play();
      //       }
      //     });
      //   },
      //   // Display the correct icon depending on the state of the player.
      //   child: Icon(
      //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),
    );
  }
}
