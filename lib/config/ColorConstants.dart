import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorConstants {
  static Color dartBlackBg = Color(0xff191919);

  static Color gray50 = Color(0xFFe9e9e9);
  static Color gray100 = Color(0xFFbdbebe);
  static Color gray200 = Color(0xFF929293);
  static Color gray300 = Color(0xFF666667);
  static Color gray400 = Color(0xFF505151);
  static Color gray500 = Color(0xFF242526);
  static Color gray600 = Color(0xFF202122);
  static Color gray700 = Color(0xFF191a1b);
  static Color gray800 = Color(0xFF121313);
  static Color gray900 = Color(0xFF0e0f0f);

  static Color dividerColor = Color(0xFFe5e5e5);
  static Color dividerColorDark = Color(0xFF111111);
  static Color dividerColorDark2 = Color(0xFF242424);
  static Color statuabarColor = Color(0xFFededed); //Color(0xFF);
  static Color bottomColor = Color(0xFFf6f6f6);
  static Color bottomColorBlack = Color(0xFF1b1b1b);
  static Color bottomTextColorBlack = Color(0xFFD2D2D2);
  static Color chatBgColor = Color(0xFFb6e889);
  static Color chatTextColorLabel = Color(0xFFa4a4a4);
  static Color color1a = Color(0xFF1a1a1a);
  static Color colorb3 = Color(0xFFb3b3b3);

  static Color greenColor = Color(0xFF57CB3D);
  static Color testColor = Color(0xFFFF0000);

  static Color greyColor = Color(0xFF919191);
  static Color inputLineColor = Color(0xFFEBEBEB);

  static Color reportColor = Color(0xFF57CB3D);
  static Color likeColor = Color(0xFFCB4FAF);// Color(0xFFCB4FAF);
  static Color lightColor = Color(0xFFFF8843);
  static Color textBlack = Color(0xFF1C1C1C);
  static Color badgeColor = Color(0xFFbc5cac);
  static Color hintColor = Color(0xFF9D9D9D);
  static Color textRed = Color(0xFFE5485D);
  static Color textGreen = Color(0xFF79D750);
  static Color zapSettingViewBG = Color(0xFFffc40f);
  static Color zapedColor = Color(0xFFEF8E53);
  static Color donateViewBG = Color(0xFFB36FD2);
  static Color tabUnSelect = Color(0xFF808080);
  static Color setPageBg = Color(0xFF141414);
  static Color dialogBg = Color(0xFF1c1c1c);
  static Color lineColorBlack = Color(0xFF242424);
  static Color searchBg = Color(0xFF191919);


  static Color hexToColor(String hex) {
    assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex));

    return Color(int.parse(hex.substring(1), radix: 16) + (hex.length == 7 ? 0xFF000000 : 0x00000000));
  }

}

