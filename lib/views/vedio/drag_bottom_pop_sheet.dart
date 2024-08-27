// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:ui';

import 'package:flutter/material.dart';

class DragBottomPopSheet extends StatefulWidget {
  const DragBottomPopSheet({
    Key? key,
    this.onClosing,
    required this.child,
    this.onDragStart,
    this.onDragEnd,
    this.onAnimationFinish,
    required this.animationController,
    required this.fadeAnimationController,
  }) : super(key: key);
  final Function? onClosing;
  final Widget child;
  final Function? onDragStart;
  final ValueChanged<Offset>? onDragEnd;
  final Function? onAnimationFinish;
  final AnimationController animationController;
  final AnimationController fadeAnimationController;

  @override
  _DragBottomPopSheetState createState() => _DragBottomPopSheetState();

  static const double minScale = 0.6;
}

class _DragBottomPopSheetState extends State<DragBottomPopSheet>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _scaleNotifier = ValueNotifier<double>(1.0);
  final ValueNotifier<Offset> _offsetNotifier =
  ValueNotifier<Offset>(Offset.zero);
  final double midDy = MediaQueryData.fromWindow(window).size.height / 2;
  bool _isBottomDir = false;

  late AnimationController _resetController;
  late Animation _resetAnimation;

  double _lastScale = 0;
  Offset _lastOffset = Offset.zero;
  double _lastFade = 0;

  late var statusListener;
  late var valueListener;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _resetAnimation = CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOut,
    )..addListener(() {
      _scaleNotifier.value =
          _resetAnimation.value * (1 - _lastScale) + _lastScale;
      widget.animationController.value =
          _resetAnimation.value * (1 - _lastFade) + _lastFade;
      double dx =
          _resetAnimation.value * (1 - _lastOffset.dx) + _lastOffset.dx;
      double dy =
          _resetAnimation.value * (1 - _lastOffset.dy) + _lastOffset.dy;
      _offsetNotifier.value = Offset(dx, dy);
      widget.onDragEnd?.call(_lastOffset);
    });

    statusListener = (status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationFinish?.call();
      }
    };
    valueListener = () {
      widget.fadeAnimationController.value = widget.animationController.value;
    };
    widget.animationController.addStatusListener(statusListener);
    widget.animationController.addListener(valueListener);
  }

  @override
  void dispose() {
    _resetController.dispose();
    widget.animationController.removeStatusListener(statusListener);
    widget.animationController.removeListener(valueListener);
    super.dispose();
  }

  void onPanStart(DragStartDetails details) {
    widget.onDragStart?.call();
  }

  void onPanUpdate(DragUpdateDetails details) {
    _offsetNotifier.value += details.delta;

    if (isChildBelowMid(_offsetNotifier.value.dy)) {
      // dy : sy = x : 1 - min
      _scaleNotifier.value = 1 -
          (_offsetNotifier.value.dy /
              midDy *
              (1 - DragBottomPopSheet.minScale));
      widget.animationController.value = 1 - (_offsetNotifier.value.dy / midDy);
    } else {
      if (_scaleNotifier.value != 1) {
        _scaleNotifier.value = 1;
        widget.animationController.value = 1;
      }
    }

    if (details.delta.dy > 0) {
      _isBottomDir = true;
    } else {
      _isBottomDir = false;
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (isChildBelowMid(_offsetNotifier.value.dy - 100)) {
      if (_isBottomDir) {
        closing();
        return;
      }
    }
    _lastScale = _scaleNotifier.value;
    _lastOffset = _offsetNotifier.value;
    _lastFade = widget.animationController.value;
    _resetController.forward(from: 0);
  }

  void onPanCancel() {}

  bool isChildBelowMid(double dy) {
    return _offsetNotifier.value.dy > 0;
  }

  void closing() {
    widget.animationController.removeListener(valueListener);
    widget.onClosing?.call();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is DragBottomStartNotification) {
          onPanStart(notification.details);
        } else if (notification is DragBottomUpdateNotification) {
          onPanUpdate(notification.details);
        } else if (notification is DragBottomEndNotification) {
          onPanEnd(notification.details);
        } else if (notification is DragBottomCancelNotification) {
          onPanCancel();
        }
        return false;
      },
      child: ValueListenableBuilder<Offset>(
        valueListenable: _offsetNotifier,
        builder: (context, offset, child) {
          return Transform.translate(
            offset: offset,
            child: ValueListenableBuilder<double>(
              valueListenable: _scaleNotifier,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: RepaintBoundary(
                    child: widget.child,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DragBottomPopGesture extends StatelessWidget {
  final Widget child;

  const DragBottomPopGesture({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        DragBottomStartNotification(details).dispatch(context);
      },
      onPanUpdate: (details) {
        DragBottomUpdateNotification(details).dispatch(context);
      },
      onPanEnd: (details) {
        DragBottomEndNotification(details).dispatch(context);
      },
      onPanCancel: () {
        DragBottomCancelNotification().dispatch(context);
      },
      child: child,
    );
  }
}

class DragBottomStartNotification extends Notification {
  final DragStartDetails details;

  DragBottomStartNotification(this.details);
}

class DragBottomUpdateNotification extends Notification {
  final DragUpdateDetails details;

  DragBottomUpdateNotification(this.details);
}

class DragBottomEndNotification extends Notification {
  final DragEndDetails details;

  DragBottomEndNotification(this.details);
}

class DragBottomCancelNotification extends Notification {
  DragBottomCancelNotification();
}