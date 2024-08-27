import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'drag_bottom_dismiss_dialog.dart';
import 'drag_bottom_pop_sheet.dart';
import 'round_slider_track_shape.dart';

class VideoPage extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final Object? heroTag;
  const VideoPage(
      {Key? key,
        required this.videoPlayerController,
        this.heroTag})
      : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    implements DragBottomDismissListener {
  late VideoPlayerController _videoPlayerController;
  final ValueNotifier<double> _processNotifier = ValueNotifier<double>(0);
  int _timeProcess = 0;
  int _total = 0;
  // int _lastPosition = 0;
  Timer? _timer;
  Timer? _hideTimer;
  bool _hasPlay = false;
  // bool _needRunTimeSync = false;
  bool _isDragging = false;
  bool _isPlaying = false;
  bool _pageDragging = false;
  bool _animationFinish = false;

  @override
  void initState() {
    super.initState();
    DragBottomDismissManager.addListener(this);
    initializePlayer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hideTimer?.cancel();
    _videoPlayerController.setVolume(0);
    DragBottomDismissManager.removeListener(this);
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = widget.videoPlayerController;
    if (!_videoPlayerController.value.isInitialized) {
      await _videoPlayerController.initialize();
    }
    _total = _videoPlayerController.value.duration.inMilliseconds;
    if (mounted) {
      setState(() {});
    }
    _videoPlayerController.setLooping(true);
    _isPlaying = true;
    if (!_pageDragging) {
      _timeProcess = _videoPlayerController.value.position.inMilliseconds;
      play();
    }
  }

  void runTimer() async {
    if (_timer?.isActive ?? false) {
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) async {
      if (!_videoPlayerController.value.isPlaying) {
        return;
      }
      _timeProcess = _videoPlayerController.value.position.inMilliseconds;
      _processNotifier.value = _timeProcess / _total;
    });
  }

  void play() async {
    _hasPlay = true;
    _timeProcess = _videoPlayerController.value.position.inMilliseconds;
    _processNotifier.value = _timeProcess / _total;
    _videoPlayerController.setVolume(100);
    await _videoPlayerController.play();
    runTimer();
  }

  void pause() async {
    await _videoPlayerController.pause();
    _timer?.cancel();
  }

  void readyToHide() {
    _hideTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _isDragging = false;
      });
    });
  }

  void onTap() {
    _videoPlayerController.pause();
    Navigator.pop(context);
    // if (_videoPlayerController.value.isInitialized) {
    //   if (_videoPlayerController.value.isPlaying) {
    //     pause();
    //     _isPlaying = false;
    //   } else {
    //     play();
    //     _isPlaying = true;
    //   }
    //   setState(() {});
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 70),
      top: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 30,
                left: 0,
                right: 0,
                child: Container(
                  // color: Colors.red,
                  width: double.maxFinite,
                  height: double.maxFinite,
                  alignment: _videoPlayerController.value.aspectRatio >= 1 ? Alignment.center : Alignment.center,
                  child: DragBottomPopGesture(
                    child: Hero(
                      tag: widget.heroTag ?? "video_page_player",
                      transitionOnUserGestures: true,
                      child: _videoPlayerController.value.isInitialized
                          ? AspectRatio(
                        aspectRatio:
                        _videoPlayerController.value.aspectRatio,
                        child: GestureDetector(
                          onTap: onTap,
                          behavior: HitTestBehavior.opaque,
                          child: VideoPlayer(_videoPlayerController),
                        ),
                      )
                          : const SizedBox(),
                    ),
                  ),
                ),
              ),

              _animationFinish &&
                  !_isDragging &&
                  !_videoPlayerController.value.isPlaying &&
                  ((!_videoPlayerController.value.isInitialized) ||
                      _videoPlayerController.value.isBuffering)
                  ? const Center(
                child: SizedBox(
                  width: 53,
                  height: 53,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    strokeWidth: 1.5,
                  ),
                ),
              )
                  : const SizedBox(),

              Center(
                child: !_videoPlayerController.value.isInitialized || _isPlaying
                    ? Container()
                    : GestureDetector(
                  onTap: onTap,
                  child: const Icon(
                    Icons.play_circle_outline,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 10,
                  width: double.maxFinite,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: Opacity(
                    opacity: _pageDragging
                        ? 0
                        : _isDragging
                        ? 1
                        : 0.5,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        activeTrackColor: Colors.grey[400],
                        inactiveTrackColor: Colors.grey[700],
                        thumbColor: Colors.white,
                        thumbShape: RoundSliderThumbShape(
                          disabledThumbRadius: 5,
                          enabledThumbRadius: _isDragging ? 5 : 3,
                        ),
                        overlayColor: Colors.transparent,
                        trackShape: const RoundSliderTrackShape(radius: 8),
                      ),
                      child: ValueListenableBuilder<double>(
                        valueListenable: _processNotifier,
                        builder: (context, process, child) {
                          return Slider(
                            value: process > 1
                                ? 1
                                : process < 0
                                ? 0
                                : process,
                            onChanged: (double value) {
                              _videoPlayerController.seekTo(Duration(
                                  milliseconds: (value * _total).toInt()));
                              _processNotifier.value = value;
                            },
                            onChangeStart: (double value) {
                              _hideTimer?.cancel();
                              _isDragging = true;
                              if (_videoPlayerController.value.isPlaying) {
                                _hasPlay = true;
                                pause();
                              } else {
                                _hasPlay = false;
                              }
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            onChangeEnd: (double value) async {
                              await _videoPlayerController.seekTo(Duration(
                                  milliseconds: (value * _total).toInt()));
                              if (_hasPlay) {
                                // _needRunTimeSync = true;
                                // _lastPosition = _videoPlayerController.value.position.inMilliseconds;
                                play();
                              }
                              readyToHide();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onDragEnd(Offset endStatus) {
    if (_hasPlay) {
      play();
    }
    if (mounted) {
      setState(() {
        _pageDragging = false;
      });
    }
  }

  @override
  void onDragStart() {
    if (_videoPlayerController.value.isPlaying) {
      _hasPlay = true;
      pause();
    } else {
      _hasPlay = false;
    }
    if (mounted) {
      setState(() {
        _pageDragging = true;
      });
    }
  }

  @override
  void onClosing() {}

  @override
  void onAnimationFinish() {
    if (mounted) {
      setState(() {
        _animationFinish = true;
      });
    }
  }
}