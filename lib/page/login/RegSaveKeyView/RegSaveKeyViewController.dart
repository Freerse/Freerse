import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freerse/helpers/bip340.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/home/home_view.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:get/get.dart';

import '../../../config/ColorConstants.dart';

class RegSaveKeyViewController extends GetxController {
  TextEditingController priKeyController = TextEditingController();
  TextEditingController pubKeyController = TextEditingController();
  late final NostrService nostrService = Get.find();
  var copy1 = false.obs;
  var copy2 = false.obs;
  var storage = FlutterSecureStorage();
  var acceptSlices = false.obs;
  var picture = "";
  var keyPair;
  var nickName= "";

  Future<void>  saveNewAccount() async {
    var content = {
      'display_name':nickName,
      'name':nickName,
      'picture':picture,
      'lud06':'',
      'website':'',
      'nip05':'',
      'banner': '',
      'about':'',
      'lud16':''
    };

    Get.defaultDialog(title: 'Login...',content: CircularProgressIndicator(
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation(ColorConstants.greenColor),
    ));
    storage.write(key: "nostrKeys", value: json.encode(keyPair.toJson()));
    await Future.delayed(const Duration(seconds: 2));
    nostrService.initKeyPairs();
    await Future.delayed(const Duration(seconds: 2));
    nostrService.userMetadataObj.setUserInfo(keyPair.publicKey, content);
    nostrService.writeEvent(jsonEncode(content), 0, []);
    var mossId = Helpers().decodeBech32('npub129z0az8lgffuvsywazww07hx75qas3veh3dazsq56z8y39v86khs2uy5gm')[0];
    print('mossId' + mossId);
    nostrService.followUser(mossId);
    await Future.delayed(const Duration(seconds: 1));
    var freerseId = Helpers().decodeBech32('npub1tqjvq0ff6detxfmuczmvkvk52sgs9fa0ppjmmgu0hnk7cn29fmaq9mz588')[0];
    nostrService.followUser(freerseId);

    await Future.delayed(const Duration(seconds: 1));
    var jackId = Helpers().decodeBech32('npub1sg6plzptd64u62a878hep2kev88swjh3tw00gjsfl8f237lmu63q0uf63m')[0];
    nostrService.followUser(jackId);

    await Future.delayed(const Duration(seconds: 2));
    Get.offAllNamed("/home");
  }

  @override
  void onInit() {
    super.onInit();

    final params = Get.arguments;
    nickName = params['nickName'];
    picture = params['picture'];

    final bip340 = Bip340();
    keyPair = bip340.generatePrivateKey();
    print(keyPair.toJson());
    priKeyController.text = keyPair.privateKeyHr;
    pubKeyController.text = keyPair.publicKeyHr;
  }


}
