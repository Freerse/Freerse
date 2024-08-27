import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/helpers.dart';
import '../../nostr/utils.dart';
import '../../services/nostr/nostr_service.dart';

class ArticleListController extends GetxController {

  ScrollController scrollController = ScrollController();

  bool _isLoadingMore = false;

  NostrService _nostrService = Get.find();

  void onInit() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >
          scrollController.position.maxScrollExtent * 0.8) {
        if(!_isLoadingMore){
          _isLoadingMore = true;
          Future.delayed(Duration(seconds: 3)).then((e) {
            _isLoadingMore = false;
          });
          loadMore();
        }
      }
    });
  }

  Future<void> refresh() async {
    _nostrService.userFeedObj.markClearArticle();
    await loadMore(refresh: true);
  }

  Future<void> loadMore({bool refresh = false}) async {
    var following = await _nostrService.getUserContacts(_nostrService.myKeys.publicKey);
    // extract public keys
    List<String> followingPubkeys = [];
    for (var f in following) {
      followingPubkeys.add(f[1]);
    }
    // add own pubkey
    followingPubkeys.add(_nostrService.myKeys.publicKey);
    if (followingPubkeys.isEmpty) {
      log("!!! no following users found !!!");
      return;
    }

    int? until;
    if (!refresh && _nostrService.userFeedObj.articleList.isNotEmpty) {
      until = _nostrService.userFeedObj.articleList.value.last.tweetedAt;
    }

    _nostrService.requestUserArticle(
        users: followingPubkeys,
        requestId: "articleQuerys"+Helpers().getRandomString(10),
        limit: 30,
        until: until,
        includeComments: false);
  }

}
