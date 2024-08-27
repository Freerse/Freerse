// ignore_for_file: overridden_fields

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './drag_bottom_pop_sheet.dart';

class DragBottomDismissDialog<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin {
  DragBottomDismissDialog({
    required this.builder,
    RouteSettings? settings,
    this.maintainState = true,
    this.needHero = true,
  }) : super(settings: settings, fullscreenDialog: true);

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  final bool needHero;

  AnimationController? _animationController;
  AnimationController? _fadeAnimationController;

  @override
  Widget buildContent(BuildContext context) {
    return DragBottomPopSheet(
      animationController: _animationController!,
      fadeAnimationController: _fadeAnimationController!,
      onClosing: () {
        DragBottomDismissManager._sendClosing();
        if (needHero) {
          _animationController!.value = 1;
          _fadeAnimationController!.animateTo(0, duration: transitionDuration);
        }
        Navigator.pop(context);
      },
      onDragStart: () {
        DragBottomDismissManager._sendDragStart();
      },
      onDragEnd: (offset) {
        DragBottomDismissManager._sendDragEnd(offset);
      },
      onAnimationFinish: () {
        DragBottomDismissManager._sendAnimationFinish();
      },
      child: builder(context),
    );
  }

  @override
  AnimationController createAnimationController() {
    if (_animationController == null) {
      _animationController = AnimationController(
        vsync: navigator!.overlay!,
        duration: transitionDuration,
        reverseDuration: transitionDuration,
      );
      _fadeAnimationController = AnimationController(
        vsync: navigator!.overlay!,
        duration: transitionDuration,
        reverseDuration: transitionDuration,
        value: 1,
      );
    }
    return _animationController!;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Stack(
      children: [
        FadeTransition(
          opacity: !needHero || isActive
              ? _animationController!
              : _fadeAnimationController!,
          child: Container(
            color: Colors.black,
          ),
        ),
        child,
      ],
    );
  }

  @override
  String? get title => null;
}

class DragBottomDismissManager {
  static final List<DragBottomDismissListener> _listeners = [];

  static void addListener(DragBottomDismissListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(DragBottomDismissListener listener) {
    _listeners.remove(listener);
  }

  static void _sendDragStart() {
    for (var listener in _listeners) {
      listener.onDragStart();
    }
  }

  static void _sendDragEnd(Offset endStatus) {
    for (var listener in _listeners) {
      listener.onDragEnd(endStatus);
    }
  }

  static void _sendClosing() {
    for (var listener in _listeners) {
      listener.onClosing();
    }
  }

  static void _sendAnimationFinish() {
    for (var listener in _listeners) {
      listener.onAnimationFinish();
    }
  }
}

abstract class DragBottomDismissListener {
  void onDragStart();

  void onDragEnd(Offset endStatus);

  void onClosing();

  void onAnimationFinish();
}