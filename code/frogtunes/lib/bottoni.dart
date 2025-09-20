import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_service.dart';

class ControlliBottoni extends StatefulWidget{
  const ControlliBottoni({super.key});

  @override
  State<ControlliBottoni> createState() => _ControlliBottoniState();
}

class _ControlliBottoniState extends State<ControlliBottoni> {
  final audio = AudioService();
  bool loop = false;
  bool shuffle = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Play / Pause
        StreamBuilder<PlayerState>(
          stream: audio.stateStream,
          builder: (_, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            return IconButton(
              icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              onPressed: () => playing ? audio.pause() : audio.play(),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: audio.previous,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: audio.next,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(loop ? Icons.repeat_one : Icons.repeat),
              color: loop ? Colors.blue : null,
              onPressed: () {
                setState(() => loop = !loop);
                audio.toggleLoop();
              },
            ),
            IconButton(
              icon: Icon(Icons.shuffle),
              color: shuffle ? Colors.blue : null,
              onPressed: () {
                setState(() => shuffle = !shuffle);
                audio.toggleShuffle();
              },
            ),
          ],
        ),
      ],
    );
  }
}
