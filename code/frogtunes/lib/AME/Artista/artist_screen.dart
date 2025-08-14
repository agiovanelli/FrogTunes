import 'package:flutter/material.dart';

class ArtistScreen extends StatelessWidget {
  final String nomeArtista;
  final String? immagineArtista;
  final List<String> canzoni;

  const ArtistScreen({
    super.key,
    required this.nomeArtista,
    this.immagineArtista,
    this.canzoni = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          nomeArtista,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Immagine artista
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                immagineArtista ??
                    "https://via.placeholder.com/200x200?text=Artista",
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 100, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Nome artista
            Text(
              nomeArtista,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Pulsante Segui
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Segui",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),

            // Titolo sezione canzoni popolari
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Brani popolari",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Lista canzoni
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: canzoni.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                  title: Text(
                    canzoni[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // Qui apri il player della canzone
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
