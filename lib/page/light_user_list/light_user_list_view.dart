import 'package:flutter/material.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:freerse/views/light_view.dart';
import 'package:freerse/views/user_view.dart';
import 'package:get/get.dart';

import '../../config/ColorConstants.dart';
import '../../services/nostr/nostr_service.dart';
import 'light_user_list_controller.dart';

class LightUserListPage extends StatelessWidget {
  late String title;
  LightUserListPage({required this.title});

  final controller = Get.put(LightUserListController(),tag: Helpers().getRandomString(12));
  late final NostrService nostrService = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(top:false,bottom:false, child:
    Scaffold(
        backgroundColor: Get.isDarkMode ? ColorConstants.dartBlackBg : Colors.white,
        appBar: AppBar(
          backgroundColor: Get.isDarkMode ? Color(0xFF111111) : Color(0xFFededed),
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
            Get.back();
          },
          ),
          title: Text(title,style: Theme.of(context).textTheme.titleLarge,),
          centerTitle: true,
        ),
        body: ListView.builder(
          itemCount: controller.lightList.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                LightComponent(lightItem: controller.lightList[index]),
                ViewUtils.oneLine(marginLeft: 85),
              ],
            );
          },
        )
    ));
  }
}
