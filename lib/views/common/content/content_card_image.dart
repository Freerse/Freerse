import 'package:favicon/favicon.dart';
import 'package:flutter/material.dart';

class ContentCardImage extends StatefulWidget {
  String? url;
  ContentCardImage({super.key, required this.url});
  @override
  ContentCardImageState createState() => ContentCardImageState();
}

class ContentCardImageState extends State<ContentCardImage> {
  late var futureBuilderFuture;

  @override
  void initState() {
    super.initState();

    futureBuilderFuture = fetchWebsiteData(widget.url!);
  }

  Future<String> fetchWebsiteData(String url) async {
    // final response = await http.get(Uri.parse(url));
    final iconUrl = await FaviconFinder.getBest(url);

    return iconUrl!.url;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureBuilderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            print("snapshot.data = ${snapshot.data}");
            String faviconurl = "${snapshot.data}";

            return SizedBox(
              width: 60,
              height: 60,
              child: Image.network(
                faviconurl,
              ),
            );

            // Text(snapshot.data!);
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Container();
          }
        } else {
          return const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: Colors.greenAccent,
            ),
          );
        }
      },
    );
  }
}
