import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/player_screen.dart';
import 'package:frogtunes/mini_player.dart';
import 'package:frogtunes/audio_service.dart';

class ArtistScreen extends StatefulWidget {
  final String artistId;
  final String nomeArtista;
  final bool type; // true se è il profilo dell'artista loggato, false altrimenti
  final bool control; // true se l'utente è un manager, false altrimenti

  const ArtistScreen({
    super.key,
    required this.artistId,
    required this.nomeArtista,
    this.type = false,
    this.control = false,
  });

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

// Schermata del profilo artista
class _ArtistScreenState extends State<ArtistScreen> {
  Future<Map<String, dynamic>?> fetchArtistInfo(String artistId) async {
    final doc = await FirebaseFirestore.instance.collection('artisti').doc(artistId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    return {
      'bio': data?['bio'] ?? '',
      'cover': data?['cover'] ?? '',
    };
  }
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkFollowing();
    if (widget.control) {
      _checkManagedArtists();
    }
  }

  // Controlla se l'utente loggato segue l'artista
  Future<void> _checkFollowing() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('utenti')
        .doc(uid)
        .collection('followedArtists')
        .doc(widget.artistId)
        .get();
    setState(() => isFollowing = doc.exists);
  }

  // Aggiunge o rimuove l'artista dalla lista degli artisti seguiti
  Future<void> _toggleFollow() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final artistRef = FirebaseFirestore.instance
        .collection('utenti')
        .doc(uid)
        .collection('followedArtists')
        .doc(widget.artistId);

    if (isFollowing) {
      await artistRef.delete();
    } else {
      await artistRef.set({
        'uid': widget.artistId,
        'nome': widget.nomeArtista,
        'cover': await fetchArtistInfo(widget.artistId).then((data) => data?['cover'] ?? ''),
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
    setState(() => isFollowing = !isFollowing);
  }

  // Controlla se il manager loggato gestisce l'artista
  Future<void> _checkManagedArtists() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('manager')
        .doc(uid)
        .collection('managedArtists')
        .doc(widget.artistId)
        .get();
    setState(() => isFollowing = doc.exists);
  }

  // Aggiunge o rimuove l'artista dalla lista degli artisti gestiti
  Future<void> _toggleManage() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final artistRef = FirebaseFirestore.instance
        .collection('manager')
        .doc(uid)
        .collection('managedArtists')
        .doc(widget.artistId);

    if (isFollowing) {
      await artistRef.delete();
    } else {
      await artistRef.set({
        'uid': widget.artistId,
        'nome': widget.nomeArtista,
        'cover': await fetchArtistInfo(widget.artistId).then((data) => data?['cover'] ?? ''),
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
    setState(() => isFollowing = !isFollowing);
  }

// Recupera i nomi degli artisti dato una lista di artistIds
Future<List<String>> fetchArtistName(List<String> artistId) async {
  if (artistId.isEmpty) return [];
  final doc = await FirebaseFirestore.instance
      .collection('artisti')
      .where(FieldPath.documentId, whereIn: artistId)
      .get();

  final Map<String, String> mappa = {
    for (var d in doc.docs) d.id: d.data()['nome'] as String? ?? 'Artista sconosciuto'
  };

  return artistId.map((id) => mappa[id] ?? 'Artista sconosciuto').toList();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041F0F),
      body: SafeArea(
        child: Stack(
          children: [
      
      FutureBuilder<Map<String, dynamic>?>(
        future: fetchArtistInfo(widget.artistId),
        builder: (context, snapshot) {
          final artistInfo = snapshot.data;
          final coverUrl = artistInfo?['cover'] ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f';
          final bio = artistInfo?['bio'] ?? '';
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(widget.nomeArtista),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: widget.type ? const SizedBox.shrink() 
                        : widget.control ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _toggleManage,
                          child: Text(
                            isFollowing ? 'Gestione attiva' : 'Gestisci artista',
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _toggleFollow,
                          child: Text(
                            isFollowing ? 'Seguito' : 'Segui',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (bio.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            bio,
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      const Text(
                        "Brani popolari",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ArtistSongs(artistId: widget.artistId, type: widget.type),
                      const SizedBox(height: 15),
                      const Text(
                        "Ultime pubblicazioni",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ArtistLastSongs(artistId: widget.artistId, type: widget.type),
                      const Text(
                        "Compare in",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ArtistFeaturing(artistId: widget.artistId, type: widget.type),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      if(!widget.control)
      const Align(
                alignment: Alignment.bottomCenter,
                child: MiniPlayer(),
          ),
          ],
        ) 
      )
    );
  }
}

// Lista dei brani dell'artista
class ArtistSongs extends StatelessWidget {
  final String artistId;
  final bool type;

  const ArtistSongs({super.key, required this.artistId, this.type = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('canzoni')
          .where('artistId', arrayContains: artistId)
          .orderBy('ascoltiTotali', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        final songs = snapshot.data!.docs;
        
        if (songs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "Nessun brano disponibile",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index){
            final song = songs[index];
            final List<String> artistIds = List<String>.from(song['artistId'] ?? []);

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song['cover'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                song['titolo'],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () async {
                if (!type) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(
                        songId: song['cid'],
                        titolo: song['titolo'],
                        artistId: artistIds,
                        cover: song['cover'],
                      ),
                    ),
                  );
                  final audio = AudioService();
                  final audioUrl = song['audioUrl'];

                  if (audioUrl == null || audioUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audio non disponibile')),
                    );
                    return;
                  }

                  final nomiArtisti = await fetchArtistName(artistIds);
                  await audio.playSong(
                    songId: song['cid'],
                    url: audioUrl,
                    title: song['titolo'],
                    artist: nomiArtisti.join(', '),
                    artistId: artistIds,
                    cover: song['cover'],
                  );
                }
              },
            );
            },
          );
        },
      );
      }
    }

// Lista delle ultime canzoni dell'artista
class ArtistLastSongs extends StatelessWidget {
  final String artistId;
  final bool type;

  const ArtistLastSongs({super.key, required this.artistId, this.type = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('canzoni')
          .where('artistId', arrayContains: artistId)
          .orderBy('addedAt', descending: true) //aggiungere quando sono state create canzoni
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        final songs = snapshot.data!.docs;
        if (songs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "Nessun brano disponibile",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final List<String> artistIds = List<String>.from(song['artistId'] ?? []);
              return GestureDetector(
                onTap: () async{
                  if (!type) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(
                        songId: song['cid'],
                        titolo: song['titolo'],
                        artistId: artistIds,
                        cover: song['cover'],
                      ),
                    ),
                  );
                  final audio = AudioService();
                  final audioUrl = song['audioUrl'];

                  if (audioUrl == null || audioUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audio non disponibile')),
                    );
                    return;
                  }

                  final nomiArtisti = await fetchArtistName(artistIds);
                  await audio.playSong(
                    songId: song['cid'],
                    url: audioUrl,
                    title: song['titolo'],
                    artist: nomiArtisti.join(', '),
                    artistId: artistIds,
                    cover: song['cover'],
                  );
                }
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          song['cover'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        song['titolo'],
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Lista delle canzoni in cui l'artista è in featuring
class ArtistFeaturing extends StatelessWidget {
  final String artistId;
  final bool type;

  const ArtistFeaturing({super.key, required this.artistId, this.type = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('canzoni')
          .where('artistId', arrayContains: artistId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        final songs = snapshot.data!.docs.where((doc) {
          final List<dynamic> artists = doc['artistId'] ?? [];
          return artists.length > 1 && artists[0] != artistId;
        }).toList();

        if (songs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "Nessun brano disponibile",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return GestureDetector(
                onTap: () async {
                  if (!type) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(
                        songId: song['cid'],
                        titolo: song['titolo'],
                        artistId: List<String>.from(song['artistId']),
                        cover: song['cover'],
                      ),
                    ),
                  );
                  final audio = AudioService();
                  final audioUrl = song['audioUrl'];

                  if (audioUrl == null || audioUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audio non disponibile')),
                    );
                    return;
                  }

                  final nomiArtisti = await fetchArtistName(List<String>.from(song['artistId']));
                  await audio.playSong(
                    songId: song['cid'],
                    url: audioUrl,
                    title: song['titolo'],
                    artist: nomiArtisti.join(', '),
                    artistId: List<String>.from(song['artistId']),
                    cover: song['cover'],
                  );
                  }
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          song['cover'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        song['titolo'],
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}