import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/views/vedio/video_page.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../config/ColorConstants.dart';
import '../common/circle_icon_btn.dart';
import 'PlayVedioPage.dart';
import 'drag_bottom_dismiss_dialog.dart';

class ContentVideoComponent extends StatefulWidget {
  String url;
  ContentVideoComponent({required this.url});
  @override
  State<StatefulWidget> createState() {
    return _ContentVideoComponent();
  }
}

class _ContentVideoComponent extends State<ContentVideoComponent> with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.url.indexOf("http") == 0) {
      _controller = VideoPlayerController.network(widget.url)
        ..initialize().then((_) {
          setState(() {});
        });
    } else {
      _controller = VideoPlayerController.file(File(widget.url))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<void> onVedioClick() async {
    Navigator.push(
      Get.context!!,
      DragBottomDismissDialog(
        builder: (context) {
          return PlayVedioPage(
            videoPlayerController: _controller,
          );
        },
      ),
    ).then((value) {
      // _videoPlayerController.setVolume(100);
      _controller.seekTo(Duration.zero);
      _controller.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _controller.value.aspectRatio > 1 ? double.maxFinite : 200,
      margin: const EdgeInsets.only(
        top: 3,
        bottom: 6,
      ),
      child: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    VideoPlayer(_controller),
                    ControlsOverlay(controller: _controller),
                    // VideoProgressIndicator(_controller, allowScrubbing: true),
                  ],
                ),
              )
            :
          GestureDetector(
            onTap: () {
              onVedioClick();
              // controller.value.isPlaying ? controller.pause() : controller.play();
              // setState(() {});
            },
            child: Container(
              width: 200, height: 300,
              color: Get.isDarkMode ? Color(0xFF202020) : Color(0xFFf7f7f7),
              child: Center(
                child: Image.asset("assets/images/vedio_play.png",  width: ScreenUtil().setWidth(18)),
              ),
            ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  ControlsOverlay({required this.controller});

  @override
  State<StatefulWidget> createState() {
    return _ControlsOverlay();
  }
}

class _ControlsOverlay extends State<ControlsOverlay> {
  late VideoPlayerController controller;

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }

  Future<void> onVedioClick() async {
    Navigator.push(
      Get.context!!,
      DragBottomDismissDialog(
        builder: (context) {
          return PlayVedioPage(
            videoPlayerController: controller,
          );
        },
      ),
    ).then((value) {
      // _videoPlayerController.setVolume(100);
      controller.seekTo(Duration.zero);
      controller.pause();
    });
  }

  Future<void> onVedioClick2() async {
    Navigator.push(
      Get.context!!,
      DragBottomDismissDialog(
        builder: (context) {
          return VideoPage(
            videoPlayerController: controller,
            heroTag: "video_page_player",
          );
        },
      ),
    ).then((value) {
      // controller.setVolume(10);
      // controller.play();

      controller.seekTo(Duration.zero);
      controller.pause();
    });
  }

  String formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(0, '2');
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            onVedioClick();
            // controller.value.isPlaying ? controller.pause() : controller.play();
            // setState(() {});
          },
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${formatDuration(Duration(seconds: controller.value.duration.inSeconds))}', style: TextStyle(color: Colors.white,)),
                  Image.asset("assets/images/vedio_play.png",  width: ScreenUtil().setWidth(18)),
                  // Icon(Icons.play_arrow, color: Colors.white, size: 25.0,),
                ],
              )
          ),
        ),
      ],
    );
  }
}
