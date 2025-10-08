import 'package:fight_blight_bmore/constants/app_style.dart';
import 'package:fight_blight_bmore/constants/font_family.dart';
import 'package:flutter/material.dart';

class VideoTimer extends StatefulWidget {
  final int beginTime;
  final ValueChanged<int> onChanged;
  VideoTimer({required this.beginTime, required this.onChanged});
  @override
  State<StatefulWidget> createState() {
    return _VideoTimerState();
  }
}

class _VideoTimerState extends State<VideoTimer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(minutes: 2));
    _controller?.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Countdown(
        animation: StepTween(
          begin: widget.beginTime,
          end: 2 * 60,
        ).animate(_controller!), onChanged: (int value) {
          widget.onChanged(value);
      },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class Countdown extends AnimatedWidget {
  Countdown({Key? key, this.animation, required this.onChanged})
      : super(key: key, listenable: animation!);
  final Animation<int>? animation;
  final ValueChanged<int> onChanged;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation?.value ?? 0);
    onChanged(animation?.value ?? 0);
    String timerText =
        '${clockTimer.inHours.remainder(60).toString().padLeft(2, '0')}:${clockTimer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(clockTimer.inSeconds.remainder(60) % 60).toString().padLeft(2, '0')}';
    return Text(
      timerText,
      style: normalTextStyle(21,
          fontFamily: FontFamily.sfProDisplay, color: Colors.white),
    );
  }
}
