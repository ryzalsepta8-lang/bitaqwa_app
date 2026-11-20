import 'package:flutter/material.dart';

class KajianVideoPlayer extends StatelessWidget {
  final Widget player;

  const KajianVideoPlayer({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: player,
    );
  }
}