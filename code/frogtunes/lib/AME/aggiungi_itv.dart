import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:frogtunes/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class ModificaCanzonePage extends StatefulWidget {
  final Map<String, dynamic> canzone;
  final String canzoneId; // ID documento Firestore

  const ModificaCanzonePage({
    super.key,
    required this.canzone,
    required this.canzoneId,
  });

  @override
  State<ModificaCanzonePage> createState() => _ModificaCanzonePageState();
}

class _ModificaCanzonePageState extends State<ModificaCanzonePage> {
  final List<String> generiDisponibili = [
    'Pop', 'Rock', 'Rap', 'Trap', 'Indie', 'Jazz', 'Classica', 'Elettronica', 'Funk', 'Soul', 'Reggae', 'Metal', 'Folk', 'Blues', 'Dance', 'Latino', 'R&B', 'Altro'
  ];
  String? generePrincipale;
  String? genereSecondario;

  // Carica un file su Firebase Storage e restituisce l'URL
  Future<String?> _uploadFile(String filePath, String folder) async {
    final fileName = Uuid().v4();
    final ref = FirebaseStorage.instance.ref('$folder/$fileName');
    try {
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Carica audio su db
  void _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      // Elimina il file precedente se esiste
      if (audioUrlController != null && audioUrlController!.isNotEmpty && audioUrlController!.startsWith('https://')) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(audioUrlController!);
          await ref.delete();
        } catch (e) {
          // Ignora errori di eliminazione
        }
      }
      final url = await _uploadFile(filePath, 'music');
      await FirebaseFirestore.instance
          .collection('canzoni')
          .doc(widget.canzoneId)
          .update({'audioUrl': url});
      setState(() {
        audioUrlController = url;
      });
    }
  }

  // Carica cover su db
  void _pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      // Elimina il file precedente se esiste
      if (coverController != null && coverController!.isNotEmpty && coverController!.startsWith('https://')) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(coverController!);
          await ref.delete();
        } catch (e) {
          // Ignora errori di eliminazione
        }
      }

      final url = await _uploadFile(filePath, 'covers');
      await FirebaseFirestore.instance
          .collection('canzoni')
          .doc(widget.canzoneId)
          .update({'cover': url});

      // Aggiorna la cover anche in recentlyPlayed di tutti gli utenti
      try {
        final audioService = AudioService();
        await audioService.updateRecentlyPlayedCover(widget.canzoneId, url.toString());
      } catch (e) {
        debugPrint('Errore aggiornamento cover in recentlyPlayed: $e');
      }

      if (!mounted) return;
      setState(() {
        coverController = url;
      });
    }
  }

  // Carica video su db
  void _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'avi', 'mov'],
    );
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;

      // Elimina il file precedente se esiste
      if (videoUrl != null && videoUrl!.isNotEmpty && videoUrl!.startsWith('https://')) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(videoUrl!);
          await ref.delete();
        } catch (e) {
          // Ignora errori di eliminazione
        }
      }

      final url = await _uploadFile(filePath, 'videos');
      
      await FirebaseFirestore.instance
          .collection('canzoni')
          .doc(widget.canzoneId)
          .update({'videoUrl': url});

        setState(() {
          videoUrl = url;
        });
    }
  }

  late TextEditingController titoloController;
  late TextEditingController artistaController;
  late TextEditingController testoController;
  String? coverController;
  String? audioUrlController;
  late TextEditingController generiController;
  late TextEditingController labelController;
  late TextEditingController autoreController;
  late TextEditingController compositoreController;
  late TextEditingController producerController;
  String? videoUrl;
  bool loading = false;

  // Recupero media fields da Firestore
  Future<void> _fetchMediaFields() async {
    final doc = await FirebaseFirestore.instance.collection('canzoni').doc(widget.canzoneId).get();
    if (doc.exists) {
      final data = doc.data() ?? {};
      if (!mounted) return;
      setState(() {
        coverController = data['cover'] ?? '';
        audioUrlController = data['audioUrl'] ?? '';
        videoUrl = data['videoUrl'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    titoloController = TextEditingController(text: widget.canzone['titolo'] ?? '');
    artistaController = TextEditingController(text: widget.canzone['artista'] ?? '');
    testoController = TextEditingController(text: widget.canzone['testo'] ?? '');
    coverController =  widget.canzone['cover'] ?? '';
    audioUrlController = widget.canzone['audioUrl'] ?? '';
    labelController = TextEditingController(text: widget.canzone['label'] ?? '');
    String defaultGenere1 = '';
    String defaultGenere2 = '';
    if (widget.canzone['generi'] is List && (widget.canzone['generi'] as List).isNotEmpty) {
      defaultGenere1 = (widget.canzone['generi'] as List).isNotEmpty ? (widget.canzone['generi'] as List)[0] : '';
      defaultGenere2 = (widget.canzone['generi'] as List).length > 1 ? (widget.canzone['generi'] as List)[1] : '';
    } else if (widget.canzone['generi'] is String) {
      defaultGenere1 = widget.canzone['generi'];
    }
    generePrincipale = defaultGenere1.isNotEmpty ? defaultGenere1 : generiDisponibili.first;
    genereSecondario = defaultGenere2.isNotEmpty ? defaultGenere2 : null;
    generiController = TextEditingController(text: generePrincipale ?? '');
    autoreController = TextEditingController(text: (widget.canzone['crediti']?['Autore'] ?? []).join(', '));
    compositoreController = TextEditingController(text: (widget.canzone['crediti']?['Compositore'] ?? []).join(', '));
    producerController = TextEditingController(text: (widget.canzone['crediti']?['Producer'] ?? []).join(', '));
    videoUrl = widget.canzone['videoUrl'];
    _fetchMediaFields();
  }

  @override
  void dispose() {
  titoloController.dispose();
  artistaController.dispose();
  testoController.dispose();
  coverController;
  audioUrlController;
  labelController.dispose();
  autoreController.dispose();
  compositoreController.dispose();
  producerController.dispose();
  generiController.dispose();
  super.dispose();
  }

  Future<void> salvaModifiche() async {
    setState(() => loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('canzoni')
          .doc(widget.canzoneId)
          .update({
        'titolo': titoloController.text,
        'artista': artistaController.text,
        'testo': testoController.text,
        'cover': coverController,
        'audioUrl': audioUrlController,
        'label': labelController.text,
        'generi': [generePrincipale ?? '', if (genereSecondario != null && genereSecondario!.isNotEmpty) genereSecondario!],
        'videoUrl': videoUrl,
        'crediti': {
          'Autore': autoreController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          'Compositore': compositoreController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          'Producer': producerController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        },
      });
      Navigator.pop(context, {
        'titolo': titoloController.text,
        'artista': artistaController.text,
        'testo': testoController.text,
        'cover': coverController,
        'audioUrl': audioUrlController,
        'label': labelController.text,
        'generi': generiController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'videoUrl': videoUrl,
        'crediti': {
          'Autore': autoreController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          'Compositore': compositoreController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          'Producer': producerController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        },
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel salvataggio: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 24, 96, 26),
        title: const Text('Modifica Canzone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: loading ? null : salvaModifiche,
          ),
        ],
      ),
      body: Padding(
        
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: titoloController,
              cursorColor: Color(0xFF00FF00),
              decoration: const InputDecoration(
                          labelText: 'Titolo',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                        ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: artistaController,
              cursorColor: Color(0xFF00FF00),
              decoration: const InputDecoration(
                          labelText: 'Artista',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                        ),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Copertina'),
                  const SizedBox(height: 8),
                  coverController.toString().isNotEmpty
                      ? Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              coverController.toString(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.music_note, size: 40, color: Colors.white);
                              },
                            ),
                          ),
                        )
                      : const Text('Nessuna copertina caricata'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.image),
                onPressed: loading ? null : _pickCover,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Audio'),
              subtitle: audioUrlController.toString().isNotEmpty
                  ? const Text('Cambia traccia audio')
                  : const Text('Nessun audio caricato'),
              trailing: IconButton(
                icon: const Icon(Icons.audiotrack),
                onPressed: loading ? null : _pickAudio,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelController,
              cursorColor: Color(0xFF00FF00),
              decoration: const InputDecoration(
                          labelText: 'Etichetta',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                        ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField2<String>(
              isExpanded: true,
              value: generePrincipale,
              decoration: const InputDecoration(
                labelText: 'Genere principale',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00FF00)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items: generiDisponibili.map((genere) {
                return DropdownMenuItem<String>(
                  value: genere,
                  child: Text(genere, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  generePrincipale = value;
                  generiController.text = value ?? '';
                });
              },
              buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 50,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 400, 
                            width: 200,     
                            offset: const Offset(0, 0), // Il menu parte dalla riga del pulsante
                          ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField2<String>(
              isExpanded: true,
              value: genereSecondario,
              decoration: const InputDecoration(
                labelText: 'Genere secondario',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00FF00)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items: [const DropdownMenuItem<String>(value: '', child: Text('Nessuno', style: TextStyle(color: Colors.white))), ...generiDisponibili.map((genere) {
                return DropdownMenuItem<String>(
                  value: genere,
                  child: Text(genere, style: const TextStyle(color: Colors.white)),
                );
              })],
              onChanged: (value) {
                setState(() {
                  genereSecondario = value == '' ? null : value;
                });
              },
              buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 50,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 300, 
                            width: 200,     
                            offset: const Offset(0, 0), // Il menu parte dalla riga del pulsante
                          ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: autoreController,
              cursorColor: Color(0xFF00FF00),
              decoration: const InputDecoration(
                          labelText: 'Autori (separati da virgola)',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                        ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: compositoreController,
              cursorColor: Color(0xFF00FF00),
              decoration: const InputDecoration(
                          labelText: 'Compositori (separati da virgola)',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                        ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: producerController,
              cursorColor: Color(0xFF00FF00),
              decoration: const InputDecoration(
                          labelText: 'Producer (separati da virgola)',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                        ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: testoController,
              cursorColor: Color(0xFF00FF00),
              decoration: const InputDecoration(
                          labelText: 'Testo della Canzone',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                        ),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Video della Canzone'),
              subtitle: videoUrl != null
                  ? Text('Cambia video musicale')
                  : const Text('Nessun video aggiunto'),
              trailing: IconButton(
                icon: const Icon(Icons.video_library),
                onPressed: loading ? null : _pickVideo,
              ),
            ),
            if (loading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}