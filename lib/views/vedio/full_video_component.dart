import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/views/vedio/video_page.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../config/ColorConstants.dart';
import '../common/circle_icon_btn.dart';
import 'drag_bottom_dismiss_dialog.dart';

class FullVideoComponent extends StatefulWidget {
  VideoPlayerController controller;

  FullVideoComponent({required this.controller});

  @override
  State<StatefulWidget> createState() {
    return _FullVideoComponent(controller: controller);
  }
}

class _FullVideoComponent extends State<FullVideoComponent> with AutomaticKeepAliveClientMixin {
  VideoPlayerController controller;
  bool inited = false;

  _FullVideoComponent({required this.controller});

  @override
  void initState() {
    super.initState();
    controller.setLooping(true);
    controller.play();
    inited = controller.value.isInitialized;
    if(!controller.value.isInitialized){
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          inited = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Center(
        child:
        //controller.value.isInitialized || inited ?
        AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(controller),
                    ControlsOverlay(controller: controller),
                    VideoProgressIndicator(controller, allowScrubbing: true, colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        backgroundColor: Colors.grey,
                    ), padding: EdgeInsets.only(top: 60.0,),)
                  ],
                ),
              )
            // : Stack(
            //     alignment: Alignment.bottomCenter,
            //     children: <Widget>[
            //       Container(
            //         width: double.infinity,
            //         height: double.infinity,
            //         child: Image.asset("assets/images/loading.gif",),
            //       ),
            //       Positioned(
            //         left: 20.w,
            //         top: Get.mediaQuery.padding.top + 1.w,
            //         child: CircleIconBtn(
            //           iconData: Icons.close,
            //           onTap: () {
            //             Get.back();
            //           },
            //         ),
            //       ),
            //     ]
            // )
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
          return VideoPage(
            videoPlayerController: controller,
            heroTag: "video_page_player",
          );
        },
      ),
    ).then((value) {
      // _videoPlayerController.setVolume(100);
      controller.seekTo(Duration.zero);
      controller.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Image.asset("assets/images/vedio_play2.png",  width: ScreenUtil().setWidth(25)),
                    // Icon(
                    //   Icons.play_arrow,
                    //   color: Colors.white,
                    //   size: 50.0,
                    //   semanticLabel: 'Play',
                    // ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            // onVedioClick();
            controller.value.isPlaying ? controller.pause() : controller.play();
            setState(() {});
          },
        ),

        Positioned(
          left: 20.w,
          top: Get.mediaQuery.padding.top + 20.w,
          child: CircleIconBtn(
            iconData: Icons.close,
            onTap: () {
              Get.back();
            },
          ),
        ),


        // Align(
        //   alignment: Alignment.topLeft,
        //   child: PopupMenuButton<Duration>(
        //     initialValue: controller.value.captionOffset,
        //     tooltip: 'Caption Offset',
        //     onSelected: (Duration delay) {
        //       controller.setCaptionOffset(delay);
        //     },
        //     itemBuilder: (BuildContext context) {
        //       return <PopupMenuItem<Duration>>[
        //         for (final Duration offsetDuration in _exampleCaptionOffsets)
        //           PopupMenuItem<Duration>(
        //             value: offsetDuration,
        //             child: Text('${offsetDuration.inMilliseconds}ms'),
        //           )
        //       ];
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(
        //         // Using less vertical padding as the text is also longer
        //         // horizontally, so it feels like it would need more spacing
        //         // horizontally (matching the aspect ratio of the video).
        //         vertical: 12,
        //         horizontal: 16,
        //       ),
        //       child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
        //     ),
        //   ),
        // ),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: PopupMenuButton<double>(
        //     initialValue: controller.value.playbackSpeed,
        //     tooltip: 'Playback speed',
        //     onSelected: (double speed) {
        //       controller.setPlaybackSpeed(speed);
        //     },
        //     itemBuilder: (BuildContext context) {
        //       return <PopupMenuItem<double>>[
        //         for (final double speed in _examplePlaybackRates)
        //           PopupMenuItem<double>(
        //             value: speed,
        //             child: Text('${speed}x'),
        //           )
        //       ];
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(
        //         // Using less vertical padding as the text is also longer
        //         // horizontally, so it feels like it would need more spacing
        //         // horizontally (matching the aspect ratio of the video).
        //         vertical: 12,
        //         horizontal: 16,
        //       ),
        //       child: Text('${controller.value.playbackSpeed}x'),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
