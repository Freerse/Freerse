import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:get/get.dart';

import '../../../config/routers.dart';
import '../../../main.dart';
import '../../../services/SpUtils.dart';
import '../../../services/nostr/metadata/metadata_injector.dart';
import '../../../services/nostr/relays/relays_injector.dart';


class SetLocaleController extends GetxController {
  late final NostrService nostrService = Get.find();

  @override
  void onInit() {
  }

  Future<void>  restartApp(BuildContext context) async {
    RelaysInjector().clear();
    MetadataInjector().clear();
    await Get.deleteAll(force: true);
    Get.reset();
    currentInitPage = Routes.INITIAL;
    await initServices(delay: false);
    RestartWidget.restartApp(context);
  }

  Future<void>  setLocale(locale, lang) async {
    SpUtil.putString("APP_LOCALE", locale + "_" + lang);
    // Get.changeTheme(ThemeData.dark());
    // MineSettingController setController = Get.find();
    // setController.refresh();
    // HomeController homeController = Get.find();
    // homeController.refresh();
    // Get.forceAppUpdate();
    Get.updateLocale(Locale(locale, lang));
    Get.back();
    // await restartApp(Get.context!!);
  }
}
