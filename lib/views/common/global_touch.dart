import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class GlobalTouch extends StatefulWidget {
  final Widget child;
  final Function(PointerEvent event, bool inSide)? onPanDown;
  final Function(PointerEvent event, bool inSide)? onPanUp;
  GlobalTouch({required this.child, this.onPanDown, this.onPanUp});
  @override
  _GlobalTouchState createState() => _GlobalTouchState();
}

class _GlobalTouchState extends State<GlobalTouch> {
  @override
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter
        .removeGlobalRoute(_handlePointerEvent);
    super.dispose();
  }

  void _handlePointerEvent(PointerEvent event) {
    final randerObject = context.findRenderObject();
    if (randerObject is RenderBox) {
      final box = randerObject;
      final target = box.localToGlobal(Offset.zero) & box.size;
      final inSide = target.contains(event.position);
      if (event is PointerUpEvent || event is PointerCancelEvent) {
        widget.onPanUp?.call(event, inSide);
      } else if (event is PointerDownEvent) {
        widget.onPanDown?.call(event, inSide);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
