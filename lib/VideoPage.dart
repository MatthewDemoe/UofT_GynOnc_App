import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

//Simple widget, just contains a youtube video player
class VideoPage extends StatelessWidget {
  VideoPage({Key key, this.title, this.id}) : super(key: key);

  final String title;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: YoutubePlayer(
              controller: YoutubePlayerController(
                  initialVideoId: id,
                  flags: YoutubePlayerFlags(autoPlay: false)),
            ),
          ),
        ]);
  }
}
