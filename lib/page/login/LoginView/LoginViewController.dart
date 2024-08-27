import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freerse/helpers/bip340.dart';
import 'package:get/get.dart';

import '../../../config/ColorConstants.dart';
import '../../../services/nostr/nostr_service.dart';

class LoginViewController extends GetxController {
  TextEditingController nameController = TextEditingController();
  var acceptSlices = false.obs;
  var storage = FlutterSecureStorage();
  NostrService nostrService = Get.find();


  Future<void>  importAccount() async {
    final bip340 = Bip340();
    var keyPair = bip340.importPrivateKey(nameController.text);
    print(keyPair.toJson());
    Get.defaultDialog(title: 'Login...',content: CircularProgressIndicator(
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation(ColorConstants.greenColor),
    ));
    storage.write(key: "nostrKeys", value: json.encode(keyPair.toJson()));
    nostrService.initKeyPairs();
    await Future.delayed(const Duration(seconds: 3));
    // Get.back();
    Get.offAllNamed("/home");
  }

  @override
  void onInit() {
    super.onInit();
  }

}
