import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPage extends StatelessWidget {
  VideoPage({Key key, this.title, this.url}) : super(key: key);

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: YoutubePlayer(
                  controller: YoutubePlayerController(
                      initialVideoId: '5yx6BWlEVcY',
                      flags: YoutubePlayerFlags(autoPlay: false)),
                ),
              ),
            ]));
  }
}
