import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/Utente/playlist.dart';
import 'package:frogtunes/audio_service.dart';

// Funzione per mostrare il bottom sheet con le opzioni della canzone
Future<void> showSongOptionsBottomSheet({
  required BuildContext context,
  required String audioUrl,
  required String songId,
  required String titolo,
  required List<String> artistId,
  required String artist,
  required String cover,
}) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Recupera tutte le playlist dell'utente
  final snapshot = await FirebaseFirestore.instance
      .collection('playlists')
      .where('uid', isEqualTo: uid)
      .get();

  final playlists = snapshot.docs;

  if(context.mounted){
    // Mostra il bottom sheet contenente le opzioni aggiunta coda e playlist
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF041F0F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.queue_music, color: Colors.white),
                title: const Text(
                  "Aggiungi alla coda",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  final audio = AudioService();
                  await audio.addToQueue({
                    'url': audioUrl,
                    'songId': songId,
                    'title': titolo,
                    'artistId': artistId,
                    'artist': artist,
                    'cover': cover,
                  });
                  if(context.mounted){
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Aggiunto alla coda")),
                    );
                  }
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text(
                  "Aggiungi alla playlist",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // Apri pop-up con le playlist
                  showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: const Text(
                        "Seleziona playlist",
                        style: TextStyle(color: Colors.white),
                      ),
                      // Se la lista delle playlist è vuota, mostra un messaggio
                      content: playlists.isEmpty
                          ? const Text(
                              "Nessuna playlist disponibile",
                              style: TextStyle(color: Colors.white),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...playlists.map((playlist) {
                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.playlist_play, color: Colors.white),
                                          title: Text(
                                            playlist['name'],
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          // Cliccando su una playlist, aggiungi la canzone a quella playlist
                                          onTap: () async {
                                            final playlistRef = FirebaseFirestore.instance
                                                .collection('playlists')
                                                .doc(playlist.id);

                                            await playlistRef.collection('canzoni').add({
                                              'url': audioUrl,
                                              'cid': songId,
                                              'titolo': titolo,
                                              'artistId': artistId,
                                              'cover': cover,
                                              'addedAt': FieldValue.serverTimestamp(),
                                            });
                                            if(context.mounted){
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Aggiunto a ${playlist['name']}"),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        const Divider(color: Colors.white24),
                                      ],
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  ListTile(
                                    leading: const Icon(Icons.add, color: Colors.white),
                                    title: const Text(
                                      "Crea nuova playlist",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    // Tasto per creare una nuova playlist
                                    onTap: () async {
                                      final uid = FirebaseAuth.instance.currentUser!.uid;

                                      await PlaylistSettings.creaPlaylist(
                                        context: context,
                                        uid: uid,
                                        canzone: {
                                          'url': audioUrl,
                                          'cid': songId,
                                          'titolo': titolo,
                                          'artistId': artistId,
                                          'cover': cover,
                                        },
                                        onPlaylistCreata: (playlist) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Playlist '${playlist['name']}' creata!")),
                                          );
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

                },
              )

            ],
          ),
        );
      },
    );
  }
}
