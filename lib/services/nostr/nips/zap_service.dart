
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bech32/bech32.dart';
import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freerse/helpers/helpers.dart';
import 'package:freerse/services/nostr/nips/nip04.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:get/get.dart';
import 'package:json_cache/json_cache.dart';

import '../../../config/ColorConstants.dart';
import '../../../nostr/nips/nip_019_hrps.dart';
import '../../../page/zap/zap_setting_view.dart';
import '../../../utils/string_utils.dart';
import '../metadata/feed_like.dart';
import '../relays/simple_relays_service.dart';
import 'nip47/wallet_connection_info.dart';

class ZapService extends GetConnect {

  NostrService nostrService = Get.find();

  // JsonCache? jsonCache;

  FlutterSecureStorage? storage;

  static final String STORAGE_KEY = "zapConfig";

  ZapConfig? zapConfig;

  WalletConnectionInfo? walletConnectionInfo;

  SimpleRelaysService? simpleRelaysService;

  Nip04 nip04 = Nip04();

  ZapService() {
    _init();
  }

  _init() async {
    print("ZapService _init");
    storage = FlutterSecureStorage();
    storage!.read(key: STORAGE_KEY).then((zapConfigText) {
      if (zapConfigText != null) {
        zapConfig = ZapConfig.fromJson(json.decode(zapConfigText));
      }

      zapConfig ??= ZapConfig();
      setDefault(zapConfig!);

      if (StringUtils.isNotBlank(zapConfig!.wallConnectUrl)) {
        walletConnectionInfo = WalletConnectionInfo.validAndParse(zapConfig!.wallConnectUrl!);
        reconect();
      }
    });
    // LocalStorageInterface prefs = await LocalStorage.getInstance();
    // jsonCache = JsonCacheCrossLocalStorage(prefs);
    // var zapConfigMap = await jsonCache!.value("zapConfig");
    // if (zapConfigMap != null) {
    //   zapConfig = ZapConfig.fromJson(zapConfigMap);
    // }
    //
    // zapConfig ??= ZapConfig();
    // setDefault(zapConfig!);
    //
    // if (StringUtils.isNotBlank(zapConfig!.wallConnectUrl)) {
    //   walletConnectionInfo = WalletConnectionInfo.validAndParse(zapConfig!.wallConnectUrl!);
    //   reconect();
    // }
  }

  void reconect() {
    if (simpleRelaysService != null) {
      simpleRelaysService!.close();
    }

    if (walletConnectionInfo != null && StringUtils.isNotBlank(walletConnectionInfo!.relay)) {
      List<String> relays = [];
      relays.add(walletConnectionInfo!.relay);
      simpleRelaysService = SimpleRelaysService(relays: relays, name: "WalletConnect", onRelayMsg: onMsg);
      simpleRelaysService!.connect();
    }
  }

  void onMsg(WebSocket socket, List list) {
    print(list);
    if (list.isNotEmpty && simpleRelaysService != null) {
      var length = list.length;
      if (list[0] == "EOSE" && length > 1) {
        var reqId = list[1];
        simpleRelaysService!.doSend(["CLOSE", reqId]);
      } else if (list[0] == "EVENT" && length > 2) {
        var reqObj = list[2];
        var content = reqObj["content"];
        String? zapEventId;
        var tags = reqObj["tags"];
        if (tags != null) {
          for (var tag in tags) {
            if (tag is List && tag.length > 1 && tag[0] == "e") {
              zapEventId = tag[1];
            }
          }
        }
        var decryptedContent = nip04.decrypt(walletConnectionInfo!.secret, walletConnectionInfo!.pubkey, content);
        // log(decryptedContent);
        if (StringUtils.isNotBlank(decryptedContent)) {
          var msgMap = jsonDecode(decryptedContent);
          if (msgMap != null) {
            var error = msgMap["error"];
            if (error != null) {
              if (zapEventId != null) {
                var feedId = _zapEventIdCache[zapEventId];
                if (feedId != null) {
                  nostrService.feedLikeObj.removeZapTempEvent(feedId, zapEventId);
                }
              }

              var message = error["message"];
              if (message != null) {
                Get.snackbar("TI_SHI".tr, "ZAP_FAIL".tr, duration: Duration(seconds: 3),);
              }
            }
          }
        }
      }
    }
  }

  void setDefault(ZapConfig _zapConfig) {
    _zapConfig.defaultNum ??= 88;
    _zapConfig.num1 ??= 21;
    _zapConfig.num2 ??= 420;
    _zapConfig.num3 ??= 1000;
    _zapConfig.num4 ??= 10000;
    _zapConfig.num5 ??= 100000;
    _zapConfig.num6 ??= 1000000;
  }

  Future<void> updateSetting() async {
    if (storage != null && zapConfig != null) {
      walletConnectionInfo = WalletConnectionInfo.validAndParse(zapConfig!.wallConnectUrl);
      var configText = jsonEncode(zapConfig!.toJson());
      await storage!.write(key: STORAGE_KEY, value: configText);
      try {
        if (walletConnectionInfo != null) {
          updateUserInfo(walletConnectionInfo!.lud16);
        }
      } catch (e) {
        log("zapService updateUserInfo error $e");
      }
    }
    // if (jsonCache != null && zapConfig != null) {
    //   zapConfig = zapConfig;
    //   walletConnectionInfo = WalletConnectionInfo.validAndParse(zapConfig!.wallConnectUrl);
    //   await jsonCache!.refresh("zapConfig", zapConfig!.toJson());
    //   try {
    //     if (walletConnectionInfo != null) {
    //       updateUserInfo(walletConnectionInfo!.lud16);
    //     }
    //   } catch (e) {
    //     log("zapService updateUserInfo error $e");
    //   }
    // }
  }

  void updateUserInfo(String? lud16) {
    if (StringUtils.isBlank(lud16)) {
      return;
    }

    var pubkey = nostrService.myKeys.publicKey;
    var userInfo = nostrService.userMetadataObj.getUserInfo(pubkey);
    userInfo ??= Map<String, dynamic>();

    if (userInfo["lud16"] != lud16) {
      userInfo["lud16"] = lud16;
      nostrService.userMetadataObj.setUserInfo(pubkey, userInfo);
      nostrService.writeEvent(jsonEncode(userInfo), 0, []);
    }
  }

  // zapEventId - eventId
  Map<String, String> _zapEventIdCache = {};

  SnackbarController? sendingSnackbarController;

  bool canZap() {
    if (simpleRelaysService == null || walletConnectionInfo == null) {
      return false;
    }
    return true;
  }

  Future<void> sendZap(String pubkey, {int? sats, String? eventId,
    String? pollOption, String? comment, Function(int amount, {String? noteId, String? pubkey})? onCompleted}) async {
    if (simpleRelaysService == null || walletConnectionInfo == null) {
      Get.to(()=> ZapSettingView());
      return;
    }
    if (sendingSnackbarController != null) {
      Get.showSnackbar(GetSnackBar(
        message: "Nostr Wallet is sending, please try it later.",
        duration: Duration(seconds: 2),
      ));

      return;
    }

    if (!checkLud16(pubkey)) {
      Get.snackbar(
        "TI_SHI".tr,
        "THIS_ACCOUNT_DOES_NOT_HAVE_A_WALLET_ADDRESS_SET".tr,
        duration: Duration(seconds: 3),
      );

      return;
    }

    sendingSnackbarController = Get.snackbar(
      "TI_SHI".tr,
      "ZAP_SENDING".tr,
      duration: Duration(seconds: 3),
      messageText: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(
                "ZAP_SENDING".tr,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
              ),),
              TextButton(
                onPressed: () {
                  _closeSendingSnackbar();
                },
                child: Text("QU_XIAO".tr, style: TextStyle(
                  color: Get.theme.colorScheme.secondary,
                ),),
              ),
            ],
          ),
          LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Get.theme.colorScheme.secondary),
          ),
        ],
      ),
    );

    // sendingSnackbarController = Get.showSnackbar(GetSnackBar(
    //   backgroundColor: ColorConstants.hexToColor("#f8f8f8"),
    //   messageText: Text(
    //     "ZAP_SENDING".tr,
    //     style: TextStyle(color: ColorConstants.hexToColor("#303030"), fontWeight: FontWeight.bold,),
    //   ),
    //   mainButton: TextButton(
    //     onPressed: () {
    //       _closeSendingSnackbar();
    //     },
    //     child: Text("QU_XIAO".tr, style: TextStyle(
    //       color: Get.theme.colorScheme.secondary,
    //     ),),
    //   ),
    //   showProgressIndicator: true,
    //   progressIndicatorBackgroundColor: ColorConstants.hexToColor("#f8f8f8"),
    //   progressIndicatorValueColor: AlwaysStoppedAnimation(Get.theme.colorScheme.secondary),
    // ));
    try {
      await Future.delayed(Duration(seconds: 1));
      sats ??= zapConfig!.defaultNum!;
      var invoiceCode = await doGenInvoiceCode(sats!, pubkey, eventId: eventId, pollOption: pollOption, comment: comment);
      print("invoiceCode $invoiceCode");
      if (StringUtils.isBlank(invoiceCode)) {
        return;
      }

      if (sendingSnackbarController != null) {
        sendingSnackbarController!.close();
        sendingSnackbarController = null;

        var sendEvent = {
          "method": "pay_invoice",
          "params": {
            "invoice": invoiceCode
          }
        };
        var sendEventText = jsonEncode(sendEvent);
        var sendEventEncryptedText = nip04.encrypt(walletConnectionInfo!.secret, walletConnectionInfo!.pubkey, sendEventText);

        var event = nostrService.genAndSignEventWithKey(walletConnectionInfo!.senderPubkey(), walletConnectionInfo!.secret,
            sendEventEncryptedText, 23194, [["p", walletConnectionInfo!.pubkey]]);

        simpleRelaysService!.sendEvent(event);

        if (eventId != null) {
          var zapEventId = event["id"];
          _zapEventIdCache[zapEventId] = eventId;
          nostrService.feedLikeObj.addZap(eventId, nostrService.myKeys.publicKey, Decimal.fromInt(sats), event["created_at"], zapEventId: zapEventId);
        }
        
        {
          simpleRelaysService!.doSend(["REQ", Helpers().getRandomString(14), {"#e": [event["id"]], "kinds": [23195]}]);
        }

        if (onCompleted != null) {
          onCompleted(sats, noteId: eventId, pubkey: pubkey);
        }
      }
    } finally {
      _closeSendingSnackbar();
    }
  }

  void _closeSendingSnackbar() {
    if (sendingSnackbarController != null) {
      sendingSnackbarController!.close();
      sendingSnackbarController = null;
    }
  }

  // Future<void> doSend(int sats, String pubkey, {String? eventId,
  //   String? pollOption, String? comment}) async {
  //
  //   var invoiceCode = await doGenInvoiceCode(sats, pubkey, eventId: eventId,
  //       pollOption: pollOption, comment: comment);
  //
  //   print(invoiceCode);
  // }

  bool checkLud16(String pubkey) {
    var userInfo = nostrService.userMetadataObj.getUserInfo(pubkey);
    if (userInfo == null) {
      return false;
    }

    var lud06 = userInfo["lud06"];
    var lud16 = userInfo["lud16"];

    // lud16 like: pavol@rusnak.io
    // but some people set lud16 to lud06
    String? lnurl = lud06;
    String? lud16Link;

    if (StringUtils.isBlank(lnurl)) {
      if (StringUtils.isNotBlank(lud16)) {
        lnurl = getLnurlFromLud16(lud16!);
      }
    }
    // check if user set wrong
    if (lnurl!.contains("@")) {
      lnurl = getLnurlFromLud16(lud16!);
    }

    if (StringUtils.isBlank(lud16Link)) {
      if (StringUtils.isNotBlank(lud16)) {
        lud16Link = getLud16LinkFromLud16(lud16!);
      }
    }
    if (StringUtils.isBlank(lud16Link)) {
      if (StringUtils.isNotBlank(lud06)) {
        lud16Link = decodeLud06Link(lud06!);
      }
    }

    if (StringUtils.isBlank(lnurl)) {
      return false;
    }

    return true;
  }

  Future<String?> doGenInvoiceCode(
      int sats, String pubkey,
      {String? eventId, String? pollOption, String? comment}) async {
    var userInfo = nostrService.userMetadataObj.getUserInfo(pubkey);
    if (userInfo == null) {
      // TODO Toast
      return null;
    }

    var lud06 = userInfo["lud06"];
    var lud16 = userInfo["lud16"];

    List<String> relays = [];
    var i = 0;
    for (var relay in nostrService.relays.connectedRelaysWrite.entries) {
      if (relay.value.socketIsRdy == true) {
        relays.add(relay.value.connectionUrl);
        i++;
        if (i > 4) {
          break;
        }
      }
    }

    // lud16 like: pavol@rusnak.io
    // but some people set lud16 to lud06
    String? lnurl = lud06;
    String? lud16Link;

    if (StringUtils.isBlank(lnurl)) {
      if (StringUtils.isNotBlank(lud16)) {
        lnurl = getLnurlFromLud16(lud16!);
      }
    }
    // check if user set wrong
    if (lnurl!.contains("@")) {
      lnurl = getLnurlFromLud16(lud16!);
    }

    if (StringUtils.isBlank(lud16Link)) {
      if (StringUtils.isNotBlank(lud16)) {
        lud16Link = getLud16LinkFromLud16(lud16!);
      }
    }
    if (StringUtils.isBlank(lud16Link)) {
      if (StringUtils.isNotBlank(lud06)) {
        lud16Link = decodeLud06Link(lud06!);
      }
    }

    if (StringUtils.isBlank(lnurl)) {
      Get.snackbar(
        "TI_SHI".tr,
        "THIS_ACCOUNT_DOES_NOT_HAVE_A_WALLET_ADDRESS_SET".tr,
        duration: Duration(seconds: 3),
      );
      return null;
    }

    return await getInvoiceCode(
      lnurl: lnurl!,
      lud16Link: lud16Link!,
      sats: sats,
      recipientPubkey: pubkey,
      relays: relays,
      eventId: eventId,
      pollOption: pollOption,
      comment: comment,
    );
  }

   String decodeLud06Link(String lud06) {
    var decoder = Bech32Decoder();
    var bech32Result = decoder.convert(lud06, 2000);
    var data = Nip019.convertBits(bech32Result.data, 5, 8, false);
    return utf8.decode(data);
  }

   String? getLud16LinkFromLud16(String lud16) {
    var strs = lud16.split("@");
    if (strs.length < 2) {
      return null;
    }

    var username = strs[0];
    var domainname = strs[1];

    return "https://$domainname/.well-known/lnurlp/$username";
  }

   String? getLnurlFromLud16(String lud16) {
    var link = getLud16LinkFromLud16(lud16);
    var data = utf8.encode(link!);
    data = Nip019.convertBits(data, 8, 5, true);

    var encoder = Bech32Encoder();
    Bech32 input = Bech32("lnurl", data);
    var lnurl = encoder.convert(input, 2000);

    return lnurl.toUpperCase();
  }

  Future<LnurlResponse?> getLnurlResponse(String link) async {
    var response = await get(link);
    print(response.body);
    if (response.body != null) {
      if (response.body is Map && StringUtils.isNotBlank(response.body["callback"])) {
        return LnurlResponse.fromJson(response.body);
      } else if (response.body is String) {
        var bodyJson = jsonDecode(response.body);
        if (StringUtils.isNotBlank(bodyJson["callback"])) {
          return LnurlResponse.fromJson(bodyJson);
        }
      }
    }

    return null;
  }

  Future<String?> getInvoiceCode({
    required String lnurl,
    required String lud16Link,
    required int sats,
    required String recipientPubkey,
    String? eventId,
    required List<String> relays,
    String? pollOption,
    String? comment,
  }) async {
    // var lnurlLink = decodeLud06Link(lnurl);
    var lnurlResponse = await getLnurlResponse(lud16Link);
    if (lnurlResponse == null) {
      return null;
    }

    var callback = lnurlResponse.callback!;
    if (callback.contains("?")) {
      callback += "&";
    } else {
      callback += "?";
    }

    var amount = sats * 1000;
    callback += "amount=$amount";

    String eventContent = "";
    if (StringUtils.isNotBlank(comment)) {
      var commentNum = lnurlResponse.commentAllowed;
      if (commentNum != null) {
        if (commentNum < comment!.length) {
          comment = comment.substring(0, commentNum);
        }
        callback += "&comment=${Uri.encodeQueryComponent(comment)}";
        eventContent = comment;
      }
    }

    var tags = [
      ["relays", ...relays],
      ["amount", amount.toString()],
      ["lnurl", lnurl],
      ["p", recipientPubkey],
    ];
    if (StringUtils.isNotBlank(eventId)) {
      tags.add(["e", eventId!]);
    }
    if (StringUtils.isNotBlank(pollOption)) {
      tags.add(["poll_option", pollOption!]);
    }
    var event = nostrService.genAndSignEvent(eventContent, 9734, tags);
    // log(jsonEncode(event));
    var eventStr = Uri.encodeQueryComponent(jsonEncode(event));
    callback += "&nostr=$eventStr";
    callback += "&lnurl=$lnurl";

    log("getInvoice callback $callback");

    var response = await get(callback);
    if (response.body != null) {
      if (response.body is Map && StringUtils.isNotBlank(response.body["pr"])) {
        return response.body["pr"];
      } else if (response.body is String) {
        var bodyJson = jsonDecode(response.body);
        if (StringUtils.isNotBlank(bodyJson["pr"])) {
          return bodyJson["pr"];
        }
      }
    }

    return null;
  }

}

class ZapConfig {

  String? wallConnectUrl;

  int? defaultNum;

  int? num1;

  int? num2;

  int? num3;

  int? num4;

  int? num5;

  int? num6;

  ZapConfig(
      {this.wallConnectUrl,
        this.defaultNum,
        this.num1,
        this.num2,
        this.num3,
        this.num4,
        this.num5,
        this.num6});

  ZapConfig.fromJson(Map<String, dynamic> json) {
    wallConnectUrl = json['wallConnectUrl'];
    defaultNum = json['defaultNum'];
    num1 = json['num1'];
    num2 = json['num2'];
    num3 = json['num3'];
    num4 = json['num4'];
    num5 = json['num5'];
    num6 = json['num6'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wallConnectUrl'] = this.wallConnectUrl;
    data['defaultNum'] = this.defaultNum;
    data['num1'] = this.num1;
    data['num2'] = this.num2;
    data['num3'] = this.num3;
    data['num4'] = this.num4;
    data['num5'] = this.num5;
    data['num6'] = this.num6;
    return data;
  }

}

class LnurlResponse {
  String? callback;
  int? maxSendable;
  int? minSendable;
  String? metadata;
  int? commentAllowed;
  String? tag;
  bool? allowsNostr;
  String? nostrPubkey;

  LnurlResponse(
      {this.callback,
        this.maxSendable,
        this.minSendable,
        this.metadata,
        this.commentAllowed,
        this.tag,
        this.allowsNostr,
        this.nostrPubkey});

  LnurlResponse.fromJson(Map<String, dynamic> json) {
    callback = json['callback'];
    maxSendable = json['maxSendable'];
    minSendable = json['minSendable'];
    metadata = json['metadata'];
    commentAllowed = json['commentAllowed'];
    tag = json['tag'];
    allowsNostr = json['allowsNostr'];
    nostrPubkey = json['nostrPubkey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['callback'] = this.callback;
    data['maxSendable'] = this.maxSendable;
    data['minSendable'] = this.minSendable;
    data['metadata'] = this.metadata;
    data['commentAllowed'] = this.commentAllowed;
    data['tag'] = this.tag;
    data['allowsNostr'] = this.allowsNostr;
    data['nostrPubkey'] = this.nostrPubkey;
    return data;
  }
}
