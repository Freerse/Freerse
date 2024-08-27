
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircleIconBtn extends StatelessWidget {

  IconData iconData;

  Color? color;

  Color? backgroundColor;

  Function? onTap;

  CircleIconBtn({
    required this.iconData,
    this.color,
    this.backgroundColor,
    this.onTap,
  });

  double width = 30.w;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.withOpacity(0.5),
          borderRadius:
          BorderRadius.circular(width),
        ),
        width: width,
        height: width,
        child: Icon(iconData, color: color ?? Colors.white, size: 20.w,),
      ),
    );
  }

}