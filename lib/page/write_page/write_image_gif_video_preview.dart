// ignore_for_file: avoid_unnecessary_containers, curly_braces_in_flow_control_structures

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WriteImageGifVidioPreView extends StatefulWidget {
  final String url;
  final String? type;
  const WriteImageGifVidioPreView({super.key, required this.url, this.type});
  @override
  WriteImageGifVidioPreViewState createState() =>
      WriteImageGifVidioPreViewState();
}

class WriteImageGifVidioPreViewState extends State<WriteImageGifVidioPreView> {
  ValueNotifier<String> imageUrl = ValueNotifier<String>("");
  ValueNotifier<bool> bShowDel = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isNotEmpty)
      return InkWell(
        onLongPress: () {},
        child: Container(
          child: CachedNetworkImage(
            imageUrl: widget.url,
            placeholder: (context, url) {
              return Container();
            },
          ),
        ),
      );

    return Container();
  }
}
