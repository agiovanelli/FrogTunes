import 'package:flutter/material.dart';
import 'audio_service.dart';
import 'player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();

    return ValueListenableBuilder<String>(
      valueListenable: audio.currentTitle,
      builder: (_, title, __) {
        if (title.isEmpty) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlayerScreen(
                  songId: audio.currentSongId.value,
                  titolo: audio.currentTitle.value,
                  artistId: audio.currentArtistId.value,
                  cover: audio.currentCover.value,
                ),
              ),
            );
          },
          child: Container(
            height: 70,
            color: const Color(0xFF041F0F),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ValueListenableBuilder<String>(
                    valueListenable: audio.currentCover,
                    builder: (_, cover, __) => Image.network(
                      cover,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      ValueListenableBuilder<String>(
                        valueListenable: audio.currentArtist,
                        builder: (_, artist, __) => Text(
                          artist,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    audio.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    audio.isPlaying ? audio.pause() : audio.play();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
