// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, prefer_const_constructors, sized_box_for_whitespace

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freerse/services/nostr/nostr_service.dart';
import 'package:freerse/utils/string_utils.dart';
import 'package:get/get.dart';

import '../../model/Tweet.dart';
import '../../page/feed_detail/feed_detail_view.dart';
import '../common/ViewUtils.dart';
import 'avatar_holder.dart';

class FeedArticleView extends StatelessWidget {
  Tweet data;

  NostrService nostrService = Get.find();

  FeedArticleView({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    Widget? articleTitleWidget;
    if (StringUtils.isNotBlank(data.coverImage)) {
      articleTitleWidget = Container(
        height: ScreenUtil().setHeight(35),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
        child: Row(
          children: [
            Expanded(
                child: Text(
              data.title,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ))
          ],
        ),
      );
    } else {
      articleTitleWidget = Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
        child: Text(
          data.title,
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
      );
    }

    var main = Container(
      padding: EdgeInsets.only(top: 4),
      child: Obx(() {
        var result = nostrService.userMetadataObj.getUserInfo(data.pubkey);
        var pic = result['picture'] ?? '';
        var name = ViewUtils.userShowName(result, userId: data.pubkey);
        return Container(
          // width: ScreenUtil().setWidth(360),
          width: double.infinity,
          height: ScreenUtil().setHeight(200),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Color(0xFF202020) : Color(0xFFf7f7f7),
            borderRadius: BorderRadius.circular(10.0),
            // border: Border.all(
            //   color: ColorConstants.inputLineColor,
            //   width: 1.0,
            // ),
            shape: BoxShape.rectangle,
          ),
          child: Column(
            children: [
              Container(
                height: ScreenUtil().setHeight(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                        ),
                        CachedNetworkImage(
                          imageUrl: pic,
                          placeholder: (context, url) => AvatarHolder(
                            width: 30,
                            height: 30,
                          ),
                          errorWidget: (context, url, error) => AvatarHolder(
                            width: 30,
                            height: 30,
                          ),
                          imageBuilder: (context, imageProvider) => Container(
                            width: ScreenUtil().setWidth(30),
                            height: ScreenUtil().setWidth(30),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                        Text(name,
                            style: TextStyle(
                                color: Color(0xFF5B6A91),
                                fontSize: ScreenUtil().setSp(14))

                            //   const TextStyle(
                            //     color: Color(0xFF5B6A91),
                            //     fontSize: ScreenUtil().setSp(14)
                            // ),
                            // style: Theme.of(context).textTheme.labelMedium,
                            ),
                      ],
                    ),
                    Image.asset("assets/images/article_label.png",
                        color: Get.isDarkMode
                            ? Color(0xFF5e5e5e)
                            : Color(0xFFb4b4b4),
                        width: ScreenUtil().setWidth(30)),
                  ],
                ),
              ),
              CachedNetworkImage(
                // placeholder: (context, url) => Image.asset(
                //   'assets/images/default_header.png',
                //   fit: BoxFit.cover,
                //   width: ScreenUtil().setWidth(360),
                //   height: ScreenUtil().setHeight(120),
                // ),
                errorWidget: (context, url, error) => SizedBox(
                  width: ScreenUtil().setWidth(360),
                  height: ScreenUtil().setHeight(50),
                ),
                imageUrl: data.coverImage ?? '',
                imageBuilder: (context, imageProvider) => Container(
                  width: ScreenUtil().setWidth(360),
                  height: ScreenUtil().setHeight(120),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
              articleTitleWidget!,
            ],
          ),
        );
      }),
    );

    return GestureDetector(
      onTap: () {
        Get.to(() => FeedDetailPage(),
            arguments: {"data": data}, preventDuplicates: false);
      },
      behavior: HitTestBehavior.translucent,
      child: main,
    );
  }
}
