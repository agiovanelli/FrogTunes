import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'coda.dart';

Future<void> showSongOptionsBottomSheet({
  required BuildContext context,
  required String titolo,
  required String artista,
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
                  'titolo': titolo,
                  'artista': artista,
                  'cover': cover,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Aggiunto alla coda")),
                );
              },
            ),
            const Divider(color: Colors.white24),
            if (playlists.isNotEmpty)
              ...playlists.map((playlist) {
                return ListTile(
                  leading: const Icon(Icons.playlist_add, color: Colors.white),
                  title: Text(
                    "Aggiungi a ${playlist['name']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    final playlistRef = FirebaseFirestore.instance
                        .collection('playlists')
                        .doc(playlist.id);

                    // Aggiungi alla subcollection "canzoni"
                    await playlistRef.collection('canzoni').add({
                      'titolo': titolo,
                      'artista': artista,
                      'cover': cover,
                      'addedAt': FieldValue.serverTimestamp(),
                    });

                    // Aggiungi anche all'array "canzoni"
                    await playlistRef.update({
                      'canzoni': FieldValue.arrayUnion([
                        {
                          'titolo': titolo,
                          'artista': artista,
                          'cover': cover,
                        }
                      ])
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Aggiunto a ${playlist['name']}",
                        ),
                      ),
                    );
                  },
                );
              }).toList()
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Nessuna playlist trovata",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
      );
    },
  );
}
