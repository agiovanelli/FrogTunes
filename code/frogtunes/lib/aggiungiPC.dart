import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'coda.dart';
import 'package:frogtunes/Utente/playlist.dart';

Future<void> showSongOptionsBottomSheet({
  required BuildContext context,
  required String songId,
  required String titolo,
  required List<String> artistId,
  required String cover,
}) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Recupera tutte le playlist dell'utente
  final snapshot = await FirebaseFirestore.instance
      .collection('playlists')
      .where('uid', isEqualTo: uid)
      .get();

  final playlists = snapshot.docs;

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
              onTap: () {
                Coda.aggiungi({
                  'cid': songId,
                  'titolo': titolo,
                  'artistId': artistId,
                  'cover': cover,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Aggiunto alla coda")),
                );
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
                                        onTap: () async {
                                          final playlistRef = FirebaseFirestore.instance
                                              .collection('playlists')
                                              .doc(playlist.id);

                                          await playlistRef.collection('canzoni').add({
                                            'cid': songId,
                                            'titolo': titolo,
                                            'artistId': artistId,
                                            'cover': cover,
                                            'addedAt': FieldValue.serverTimestamp(),
                                          });

                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Aggiunto a ${playlist['name']}"),
                                            ),
                                          );
                                        },
                                      ),
                                      const Divider(color: Colors.white24),
                                    ],
                                  );
                                }).toList(),
                                const SizedBox(height: 8),
                                ListTile(
                                  leading: const Icon(Icons.add, color: Colors.white),
                                  title: const Text(
                                    "Crea nuova playlist",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () async {
                                    PlaylistSettings(); // attualmente non funzionante
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
