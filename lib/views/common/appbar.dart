import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class FreeAppBar extends StatelessWidget implements PreferredSizeWidget {

  Widget? title;

  PreferredSizeWidget? bottom;

  Widget? leading;

  FreeAppBar({
    this.title,
    this.bottom,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    Widget? top;
    if (leading != null) {
      top = Row(
        children: [
          leading!,
          Expanded(child: Container(
            alignment: Alignment.center,
            child: title != null ? title! : null,
          )),
          Container(width: 56,),
        ],
      );
    } else {
      top = Container(
        child: title,
      );
    }

    list.add(Container(
      height: ScreenUtil().setHeight(Get.theme.appBarTheme.toolbarHeight!),
      alignment: Alignment.center,
      child: top,
    ));

    if (bottom != null) {
      list.add(bottom!);
    }

    return Container(
      padding: EdgeInsets.only(top: Get.mediaQuery.padding.top),
      color: Get.theme.appBarTheme.backgroundColor,
      height: preferredSize.height,
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );
  }

  @override
  Size get preferredSize {
    var toolbarHeight = Get.theme.appBarTheme.toolbarHeight;

    if (bottom != null) {
      return Size.fromHeight(ScreenUtil().setHeight(toolbarHeight!) + Get.mediaQuery.padding.top + bottom!.preferredSize.height);
    }

    return Size.fromHeight(ScreenUtil().setHeight(toolbarHeight!) + Get.mediaQuery.padding.top);
  }

}
