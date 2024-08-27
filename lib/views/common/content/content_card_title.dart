import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class ContentCardTitle extends StatefulWidget {
  String? url;
  ContentCardTitle({super.key, required this.url});
  @override
  ContentCardTitleState createState() => ContentCardTitleState();
}

class ContentCardTitleState extends State<ContentCardTitle> {
  late var futureBuilderFuture;

  @override
  void initState() {
    super.initState();

    futureBuilderFuture = fetchWebsiteTitle(widget.url!);
  }

  Future<String> fetchWebsiteTitle(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = parse(response.body);
      final title = document.querySelector('title')?.text;
      print("website title = $title");
      return title ?? 'No title found';
    } else {
      throw Exception('Failed to load the website');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureBuilderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            print("snapshot.data = ${snapshot.data}");
            String title = "${snapshot.data}";

            return SizedBox(
              width: 150,
              child: Text(
                title,
                style: const TextStyle(
                    decoration: TextDecoration.none, fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );

            // Text(snapshot.data!);
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }
}
