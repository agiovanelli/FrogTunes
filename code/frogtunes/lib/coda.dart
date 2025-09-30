import 'package:frogtunes/audio_service.dart';

class Coda {
  // Lista delle canzoni in coda
  static final List<Map<String, dynamic>> coda = [];

  // Funzione per aggiungere una canzone alla coda
  static void aggiungi(Map<String, dynamic> song) {
    coda.add(song);
  }

  // Funzione per rimuovere una canzone dalla coda tramite l'indice
  static void rimuovi(int index) {
    if (index >= 0 && index < coda.length) {
      coda.removeAt(index);
    }
  }

  // Funzione per cancellare tutta la coda
  static void cancellaCoda() {
    coda.clear();
  }

  // Funzione per ottenere la coda corrente (immutabile)
  static List<Map<String, dynamic>> getCoda() {
    return List.unmodifiable(coda);
  }

  // Funzione per riprodurre una canzone dalla coda tramite l'indice
  static void playFrom(int index, AudioService audio) {
    if (index < 0 || index >= coda.length) return;

    // Rimuove tutte le canzoni prima di questa
    coda.removeRange(0, index);

    // Prendi la canzone corrente
    final song = coda.first;

    // Riproduci tramite AudioService
    audio.playSong(
      songId: song['songId'],
      url: song['url'],
      title: song['title'],
      artistId: List<String>.from(song['artistId']),
      artist: song['artist'] ?? 'Artista sconosciuto',
      cover: song['cover'],
    );
  }
  
  // Funzione per caricare una playlist intera nella coda
  static void loadPlaylist(List<Map<String, dynamic>> playlistSongs) {
      // Sostituisce la coda corrente con la playlist a partire da startIndex
      coda.clear();
      coda.addAll(playlistSongs);
    }
}