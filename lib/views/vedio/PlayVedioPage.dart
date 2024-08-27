import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'full_video_component.dart';

class PlayVedioPage extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const PlayVedioPage({Key? key, required this.videoPlayerController})
      : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

  class _VideoPageState extends State<PlayVedioPage>   {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        // minimum: const EdgeInsets.only(bottom: 70),
        top: false,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                child: FullVideoComponent(controller: widget.videoPlayerController)
            )
        )
    );
  }


}