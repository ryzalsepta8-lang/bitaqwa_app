import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../widgets/kajian/kajian_video_player.dart';
import '../widgets/kajian/kajian_description_card.dart';

class DetailKajianPage extends StatefulWidget {
  final Map<String, String> video;

  const DetailKajianPage({super.key, required this.video});

  @override
  State<DetailKajianPage> createState() => _DetailKajianPageState();
}

class _DetailKajianPageState extends State<DetailKajianPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // Ambil Video ID dari URL YouTube
    final videoId =
        YoutubePlayerController.convertUrlToId(widget.video['url']!) ?? '';

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.video['title']!)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KajianVideoPlayer(player: player),
                const SizedBox(height: 20),
                KajianDescriptionCard(video: widget.video),
              ],
            ),
          ),
        );
      },
    );
  }
}