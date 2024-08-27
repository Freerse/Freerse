import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freerse/config/ColorConstants.dart';
import 'package:freerse/helpers/bip340.dart';
import 'package:freerse/views/common/ViewUtils.dart';
import 'package:get/get.dart';
import 'package:status_bar_control/status_bar_control.dart';

class SplashViewController extends GetxController {
  TextEditingController nameController = TextEditingController();
  var storage = FlutterSecureStorage();

  @override
  void onInit() {
    ViewUtils.changeStateColor();
    checkLogin();
  }

  Future<void> checkLogin() async {
    var nostrKeys = await storage.read(key: "nostrKeys");
    if (nostrKeys == null) {
      return;
    }
    var nostrKeysString = nostrKeys as String;
    // print("checkLogin nostrKeysString=" + nostrKeysString);
    if(nostrKeysString == '' || nostrKeysString == '{}'){
      return;
    }
    var keyPair = KeyPair.fromJson(json.decode(nostrKeysString));
    if(keyPair.privateKeyHr != ''){
      Get.offAllNamed("/home");
    }
  }
}
