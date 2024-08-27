
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freerse/page/zap/zap_number_input_component.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../helpers/helpers.dart';
import 'zap_number_setting_controller.dart';

class ZapNumberSettingView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _ZapNumberSettingView();
  }

}

class _ZapNumberSettingView extends State<ZapNumberSettingView> {

  double mainPadding = 24;

  ZapNumberSettingController controller = Get.put(ZapNumberSettingController(), tag: Helpers().getRandomString(12));

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(Text("DEFAULT_ZAP_AMOUNT_IN_SATS".tr));
    list.add(Container(
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 2),
            child: Text("sat", style: TextStyle(
              fontSize: 18.33,
              fontWeight: FontWeight.bold,
            ),),
          ),
          Expanded(child: Container(
            margin: EdgeInsets.only(left: 10),
            child: TextField(
              controller: controller.defaultTextController,
              keyboardType: Platform.isIOS ? const TextInputType.numberWithOptions(
                signed: true,
              ) : TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                isCollapsed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(
                fontSize: 33.33,
                color: ColorConstants.hexToColor("#EF8E53"),
              ),
              onEditingComplete: () {
                controller.completeUpdate();
                FocusManager.instance.primaryFocus!.unfocus();
              },
            ),
          )),
        ],
      ),
    ));
    list.add(Divider());
    list.add(Container(
      child: Text(
        "ZAP_AMOUNT_TIP".tr,
        style: Get.theme.textTheme.labelMedium!.merge(TextStyle(color: Get.isDarkMode ? Color(0xFF5e5e5e) : Color(0xFF919191)),),
      ),
    ));

    list.add(Container(
      margin: EdgeInsets.only(top: 40, bottom: 30),
      child: Text("SET_CUSTOM_ZAP_AMOUNT".tr),
    ));

    list.add(Row(
      children: [
        Expanded(child: ZapNumberInputComponent(viewController: controller, textController: controller.text1Controller,)),
        Container(width: 10),
        Expanded(child: ZapNumberInputComponent(viewController: controller, textController: controller.text2Controller,)),
        Container(width: 10),
        Expanded(child: ZapNumberInputComponent(viewController: controller, textController: controller.text3Controller,)),
      ],
    ));

    list.add(Container(height: 10,));

    list.add(Row(
      children: [
        Expanded(child: ZapNumberInputComponent(viewController: controller, textController: controller.text4Controller,)),
        Container(width: 10),
        Expanded(child: ZapNumberInputComponent(viewController: controller, textController: controller.text5Controller,)),
        Container(width: 10),
        Expanded(child: ZapNumberInputComponent(viewController: controller, textController: controller.text6Controller,)),
      ],
    ));

    list.add(Container(height: 20,));

    list.add(Row(
      children: [
        Expanded(child: Container()),
        GestureDetector(
          onTap: () {
            controller.resetNumber();
            setState(() {
            });
          },
          behavior: HitTestBehavior.translucent,
          child: Text("RESTORE_DEFAULT_SETTINGS".tr, style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: ColorConstants.hexToColor("#7AD850"),
          ),),
        ),
      ],
    ));
    
    return Scaffold(
      backgroundColor: Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          iconSize: 30,
          icon: Icon(Icons.chevron_left),
        ),
        title: Text("ZAP_AMOUNT_SETTINGS".tr,style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: mainPadding, right: mainPadding, top: mainPadding / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list,
          ),
        ),
      ),
    );
  }

}