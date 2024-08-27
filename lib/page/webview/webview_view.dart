
import 'package:flutter/material.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'webview_view_controller.dart';

class WebviewView extends StatelessWidget {

  late String title;

  WebviewView({required this.title});

  final controller = Get.put(WebviewViewController(), tag: Helpers().getRandomString(12));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top:false,
      bottom:false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            iconSize: 30,
            icon: Icon(Icons.chevron_left), onPressed: () {
            Get.back();
          },
          ),
          title: Text(title,style: Theme.of(context).textTheme.titleLarge,),
          centerTitle: true,
        ),
        body: WebViewWidget(
          controller: controller.webVeiwController,
        ),
      ),
    );
  }

}