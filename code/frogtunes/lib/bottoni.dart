import 'package:flutter/material.dart';

class ControlliBottoni {
  bool isPlaying = false;
  bool isShuffle = false;
  bool isLoop = false;

  void togglePlayPause(VoidCallback updateState) {
    isPlaying = !isPlaying;
    updateState();
    // Qui metti il codice per play/pause reale se hai un player
  }

  void skipNext() {
    // Logica per canzone successiva
  }

  void skipPrevious() {
    // Logica per canzone precedente
  }

  void toggleShuffle(VoidCallback updateState) {
    isShuffle = !isShuffle;
    updateState();
    // Logica shuffle qui
  }

  void toggleLoop(VoidCallback updateState) {
    isLoop = !isLoop;
    updateState();
    // Logica loop qui
  }
}
