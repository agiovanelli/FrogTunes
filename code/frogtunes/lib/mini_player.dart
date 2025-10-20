import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_service.dart';
import 'player_screen.dart';

// Mini player che mostra la traccia corrente e i controlli di riproduzione
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();

    // Aggiorna il mini player quando cambia la traccia
    return ValueListenableBuilder<String>(
      valueListenable: audio.currentTitle,
      builder: (_, title, __) {
        if (title.isEmpty) return const SizedBox.shrink();

        // Mini player visibile solo se c'è una traccia in riproduzione
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF041F0F),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              border: const Border(
                top: BorderSide(
                  color: Colors.green,
                  width: 1.2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
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
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.music_note, size: 40, color: Colors.white),
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
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      ValueListenableBuilder<String>(
                        valueListenable: audio.currentArtist,
                        builder: (_, artist, __) => Text(
                          artist,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stream del player per aggiornare l'icona in tempo reale
                StreamBuilder<PlayerState>(
                  stream: audio.stateStream,
                  builder: (context, snapshot) {
                    // Stato di riproduzione attuale
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton(
                      icon: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        // Toggle play/pause in base allo stato del player
                        if (playing) {
                          await audio.pause();
                        } else {
                          await audio.play();
                        }
                      },
                    );
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
