
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/page/zap/zap_number_setting_controller.dart';
import 'package:freerse/utils/string_utils.dart';

import '../../config/ColorConstants.dart';
import 'zap_number_show_component.dart';

class ZapNumberInputComponent extends StatefulWidget {

  ZapNumberSettingController viewController;

  TextEditingController textController;

  ZapNumberInputComponent({
    required this.viewController,
    required this.textController,
  });

  @override
  State<StatefulWidget> createState() {
    return _ZapNumberInputComponent();
  }

}

class _ZapNumberInputComponent extends State<ZapNumberInputComponent> {

  FocusNode focusNode = FocusNode();

  bool editing = false;

  @override
  Widget build(BuildContext context) {
    var zapWidget = Container(
      margin: EdgeInsets.only(left: 4, right: 4),
      child: Image.asset("assets/images/zapsetting_zap_orange.png",
        width: ScreenUtil().setWidth(11.67),
        height: ScreenUtil().setWidth(21),
      ),
    );

    if (editing) {
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: ScreenUtil().setWidth(22), bottom: ScreenUtil().setWidth(22)),
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorConstants.hexToColor("#EF8E53"),
            width: 1.67,
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.33)),
        ),
        child: TextField(
          controller: widget.textController,
          focusNode: focusNode,
          keyboardType: Platform.isIOS ? const TextInputType.numberWithOptions(
                signed: true,
              ) : TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            prefix: zapWidget,
            isCollapsed: true,
          ),
          onTapOutside: (e) {
            closeEdit();
          },
          onEditingComplete: closeEdit,
          style: TextStyle(
            color: ColorConstants.hexToColor("#EF8E53"),
            fontSize: 23.33,
          ),
        ),
      );
    } else {
      var text = widget.textController.value.text;

      return GestureDetector(
        onTap: beginEdit,
        behavior: HitTestBehavior.translucent,
        child: ZapNumberShowComponent(text: text),
      );
    }
  }

  void beginEdit() {
    setState(() {
      editing = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  void closeEdit() {
    focusNode.unfocus();
    setState(() {
      editing = false;
    });
    widget.viewController.completeUpdate();
  }
}