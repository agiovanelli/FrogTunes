import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/AME/Artista/artist_screen.dart';
import 'package:frogtunes/coda.dart';
import 'bottoni.dart';

class PlayerScreen extends StatefulWidget {
  final String songId;
  final String titolo;
  final String artista;
  final String cover;

  const PlayerScreen({
    super.key,
    required this.songId,
    required this.titolo,
    required this.artista,
    required this.cover,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

Future<void> toggleLikeSong({
  required String songId,
  required String titolo,
  required String artista,
  required String cover,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final songRef = FirebaseFirestore.instance
      .collection('utenti')
      .doc(user.uid)
      .collection('likedSongs')
      .doc(songId);

  final doc = await songRef.get();

  if (doc.exists) {
    // Se già piaciuta → rimuovi
    await songRef.delete();
  } else {
    // Se non piaciuta → aggiungi
    await songRef.set({
      'titolo': titolo,
      'artista': artista,
      'cover': cover,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }
}

class _PlayerScreenState extends State<PlayerScreen> {
  final ControlliBottoni controls = ControlliBottoni();

  void _mostraCoda(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF041F0F),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final queue = Coda.getCoda();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Coda di riproduzione',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () {
                        Coda.cancellaCoda();
                        setStateModal(() {});
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: queue.isEmpty
                        ? const Center(
                            child: Text(
                              "La coda è vuota",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: queue.length,
                            itemBuilder: (context, index) {
                              final song = queue[index];
                              return ListTile(
                                leading: const Icon(Icons.music_note, color: Colors.white),
                                title: Text(
                                  song['titolo'] ?? 'Senza titolo',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  song['artista'] ?? 'Sconosciuto',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    Coda.rimuovi(index);
                                    setStateModal(() {});
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _likeButton(String songId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final songRef = FirebaseFirestore.instance
        .collection('utenti')
        .doc(user.uid)
        .collection('likedSongs')
        .doc(songId);

    return StreamBuilder<DocumentSnapshot>(
      stream: songRef.snapshots(),
      builder: (context, snapshot) {
        final isLiked = snapshot.data?.exists ?? false;

        return IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.green : Colors.white,
          ),
          onPressed: () {
            toggleLikeSong(
              songId: songId,
              titolo: widget.titolo,
              artista: widget.artista,
              cover: widget.cover,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('In riproduzione', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          _likeButton(widget.songId),
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.white),
            onPressed: () => _mostraCoda(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.cover,
                height: 300,
                width: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.music_note, size: 100, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.titolo,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArtistScreen(
                      nomeArtista: widget.artista,
                    ),
                  ),
                );
              },
              child: Text(
                widget.artista,
                style: const TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Slider(
              value: 30,
              max: 100,
              onChanged: (_) {},
              activeColor: Colors.green,
              inactiveColor: Colors.white30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("1:10", style: TextStyle(color: Colors.white70)),
                Text("3:45", style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle, size: 30),
                  color: controls.isShuffle ? Colors.green : Colors.white,
                  onPressed: () {
                    setState(() {
                      controls.toggleShuffle(() => setState(() {}));
                    });
                  },
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 40),
                  onPressed: () {
                    controls.skipPrevious();
                  },
                  color: Colors.white,
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: Icon(
                    controls.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 60,
                  ),
                  onPressed: () {
                    controls.togglePlayPause(() => setState(() {}));
                  },
                  color: Colors.white,
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40),
                  onPressed: () {
                    controls.skipNext();
                  },
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    controls.isLoop ? Icons.repeat_one : Icons.repeat,
                    size: 30,
                  ),
                  color: controls.isLoop ? Colors.green : Colors.white,
                  onPressed: () {
                    setState(() {
                      controls.toggleLoop(() => setState(() {}));
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
