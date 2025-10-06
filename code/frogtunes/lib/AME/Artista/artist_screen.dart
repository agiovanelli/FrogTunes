import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frogtunes/player_screen.dart';

class ArtistScreen extends StatefulWidget {
  final String artistId;
  final String nomeArtista;
  final String? immagineArtista;

  const ArtistScreen({
    super.key,
    required this.artistId,
    required this.nomeArtista,
    this.immagineArtista,
  });

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkFollowing();
  }

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
        'cover': widget.immagineArtista ?? 'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f',
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
    setState(() => isFollowing = !isFollowing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041F0F),
      body: CustomScrollView(
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
                    widget.immagineArtista ??
                        'https://firebasestorage.googleapis.com/v0/b/frogtunes25-giovanelli.firebasestorage.app/o/default_images%2Fdefault.jpg?alt=media&token=15312b28-eaca-448f-955b-a2e484499d0f',
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
                    child: ElevatedButton(
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
                  const Text(
                    "Brani popolari",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ArtistSongs(artistId: widget.artistId),
                  const Text(
                    "Ultime pubblicazioni",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ArtistLastSongs(artistId: widget.artistId),
                  const Text(
                    "Compare in",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ArtistFeaturing(artistId: widget.artistId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista dei brani di un artista specifico
class ArtistSongs extends StatelessWidget {
  final String artistId;

  const ArtistSongs({super.key, required this.artistId});

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
          itemBuilder: (context, index) {
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
              onTap: () {
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
              },
            );
          },
        );
      },
    );
  }
}

class ArtistLastSongs extends StatelessWidget {
  final String artistId;

  const ArtistLastSongs({super.key, required this.artistId});

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

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) {
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
              onTap: () {
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
              },
            );
          },
        );
      },
    );
  }
}

class ArtistFeaturing extends StatelessWidget {
  final String artistId;

  const ArtistFeaturing({super.key, required this.artistId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('canzoni')
          .where('artistId', arrayContains: artistId) //impostare quando c'è artista ma non come primo presente in lista
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

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];

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
              onTap: () {
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
              },
            );
          },
        );
      },
    );
  }
}