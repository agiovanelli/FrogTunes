import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';


class AddReleasePage extends StatefulWidget {
  final List<String> artistIds;
  final bool isSingle;

  const AddReleasePage({
    super.key,
    required this.artistIds,
    required this.isSingle,
  });

  @override
  State<AddReleasePage> createState() => _AddReleasePageState();
}

class _AddReleasePageState extends State<AddReleasePage> {
  // Generi preimpostati
  final List<String> generiDisponibili = [
    'Pop', 'Rock', 'Rap', 'Trap', 'Indie', 'Jazz', 'Classica', 'Elettronica', 'Folk', 'Reggae', 'Metal', 'Soul', 'R&B', 'Dance', 'Latino', 'Blues', 'Country', 'Punk', 'Funk', 'Altro'
  ];
  List<String> generiSelezionati = [];
  
  // Per la modalità album
  List<Map<String, dynamic>> albumTracks = [];

  void _addTrack() async {
  List<String> trackGeneri = [];
    final titleController = TextEditingController();
    String? audioUrl;
    String? coverUrl;

  await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.green[900],
              title: const Text('Aggiungi brano', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Titolo brano'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: trackGeneri.isNotEmpty ? trackGeneri[0] : null,
                      items: generiDisponibili.map((genere) {
                        return DropdownMenuItem(
                          value: genere,
                          child: Text(genere),
                        );
                      }).toList(),
                      decoration: const InputDecoration(labelText: 'Genere principale'),
                      onChanged: (value) {
                        setStateDialog(() {
                          if (value != null) {
                            if (trackGeneri.isEmpty) {
                              trackGeneri.add(value);
                            } else {
                              trackGeneri[0] = value;
                            }
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: trackGeneri.length > 1 ? trackGeneri[1] : null,
                      items: generiDisponibili.map((genere) {
                        return DropdownMenuItem(
                          value: genere,
                          child: Text(genere),
                        );
                      }).toList(),
                      decoration: const InputDecoration(labelText: 'Genere secondario (opzionale)'),
                      onChanged: (value) {
                        setStateDialog(() {
                          if (value != null) {
                            if (trackGeneri.length < 2) {
                              trackGeneri.add(value);
                            } else {
                              trackGeneri[1] = value;
                            }
                          } else {
                            if (trackGeneri.length == 2) trackGeneri.removeAt(1);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        _pickAudio();
                        setStateDialog(() {
                          audioUrl = _audioUrl;
                        });
                      },
                      child: Text(audioUrl == null ? 'Carica la release' : 'Audio caricato'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        _pickCover();
                        setStateDialog(() {
                          coverUrl = _coverUrl;
                        });
                      },
                      child: Text(coverUrl == null ? 'Carica la cover' : 'Cover caricata'),
                    ),
                  ],
              ),
            ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      albumTracks.add({
                        'titolo': titleController.text,
                        'audioUrl': audioUrl,
                        'cover': coverUrl,
                        'generi': List<String>.from(trackGeneri),
                      });
                      setState(() {});
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Aggiungi', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
  final _formKey = GlobalKey<FormState>();
  late bool isSingle;
  final TextEditingController _albumController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final Map<String, List<String>> _crediti = {
    'Autore': [],
    'Compositore': [],
    'Producer': [],
  };

  String? _audioUrl;
  String? _coverUrl;
  bool _loading = false;

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

  void _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final url = await _uploadFile(filePath, 'music');
      setState(() {
        _audioUrl = url;
      });
    }
  }

  void _pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final url = await _uploadFile(filePath, 'covers');
      setState(() {
        _coverUrl = url;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    isSingle = widget.isSingle;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _audioUrl == null || _coverUrl == null) return;
    setState(() => _loading = true);

    final release = {
      'addedAt': DateTime.now().millisecondsSinceEpoch,
      'album': _albumController.text,
      'artistId': widget.artistIds,
      'isSingle': isSingle,
      'ascoltiTotali': 0,
      'audioUrl': _audioUrl,
      'cid': Uuid().v4(),
      'cover': _coverUrl,
      'crediti': _crediti,
      'statPaese': 0,
      'titolo': _titleController.text,
      'generi': generiSelezionati,
      'tracks': isSingle ? null : albumTracks,
    };

    FirebaseFirestore.instance.collection('canzoni').add(release);

    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aggiungi una nuova release')),
      body: Padding(
        padding: const EdgeInsets.all(16),
            child: isSingle
                ? Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Titolo'),
                          validator: (v) => v == null || v.isEmpty ? 'Campo obbligatorio' : null,
                        ),
                        TextFormField(
                          controller: _albumController,
                          decoration: const InputDecoration(labelText: 'Nome album'),
                          validator: (v) => v == null || v.isEmpty ? 'Campo obbligatorio' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: generiSelezionati.isNotEmpty ? generiSelezionati[0] : null,
                          items: generiDisponibili.map((genere) {
                            return DropdownMenuItem(
                              value: genere,
                              child: Text(genere),
                            );
                          }).toList(),
                          decoration: const InputDecoration(labelText: 'Genere principale'),
                          onChanged: (value) {
                            setState(() {
                              if (value != null) {
                                if (generiSelezionati.isEmpty) {
                                  generiSelezionati.add(value);
                                } else {
                                  generiSelezionati[0] = value;
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: generiSelezionati.length > 1 ? generiSelezionati[1] : null,
                          items: generiDisponibili.map((genere) {
                            return DropdownMenuItem(
                              value: genere,
                              child: Text(genere),
                            );
                          }).toList(),
                          decoration: const InputDecoration(labelText: 'Genere secondario (opzionale)'),
                          onChanged: (value) {
                            setState(() {
                              if (value != null) {
                                if (generiSelezionati.length < 2) {
                                  generiSelezionati.add(value);
                                } else {
                                  generiSelezionati[1] = value;
                                }
                              } else {
                                if (generiSelezionati.length == 2) generiSelezionati.removeAt(1);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _pickAudio,
                          child: Text(_audioUrl == null ? 'Carica la release' : 'Release caricata'),
                        ),
                        ElevatedButton(
                          onPressed: _pickCover,
                          child: Text(_coverUrl == null ? 'Carica la cover' : 'Cover caricata'),
                        ),
                        const SizedBox(height: 16),
                        ..._crediti.keys.map((key) => TextFormField(
                              decoration: InputDecoration(labelText: '$key (separati da virgola)'),
                              onChanged: (v) => _crediti[key] = v.split(',').map((e) => e.trim()).toList(),
                            )),
                        const SizedBox(height: 24),
                        _loading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _submit,
                                child: const Text('Invia'),
                              ),
                      ],
                    ),
                  ) : Center(
                    child: SizedBox(
                      width: 500,
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.album, size: 80, color: Colors.green),
                      const SizedBox(height: 24),
                      const Text(
                        'Carica i brani che compongono il tuo album:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _addTrack,
                        icon: const Icon(Icons.add),
                        label: const Text('Aggiungi brano'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: albumTracks.isEmpty
                            ? const Center(child: Text('Nessun brano aggiunto.', style: TextStyle(color: Colors.white)))
                            : ListView.builder(
                                itemCount: albumTracks.length,
                                itemBuilder: (context, index) {
                                  final track = albumTracks[index];
                                  return Card(
                                    color: Colors.green[800],
                                    child: ListTile(
                                      title: Text(track['titolo'] ?? '', style: const TextStyle(color: Colors.white)),
                                      subtitle: Text(
                                        'Audio: ${track['audioUrl'] ?? 'Non caricato'}\nCover: ${track['cover'] ?? 'Non caricata'}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
          ),
        );
    }
  }