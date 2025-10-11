import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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

  // Gestione più artisti
  bool _altriArtistiSingolo = false;
  String _tipoArtistaSingolo = 'featuring';
  final TextEditingController _altriArtistiControllerSingolo = TextEditingController();

  // Funzione per aggiungere un brano alla lista dell'album
  void _addTrack() async {
  List<String> trackGeneri = [];
    final titleController = TextEditingController();
    String? audioUrl;
    String? coverUrl;

  await showDialog(
    context: context,
    builder: (context) {
      bool altriArtistiSingolo = false;
      String tipoArtistaSingolo = 'featuring';
      final TextEditingController altriArtistiControllerSingolo = TextEditingController();
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.green[900],
            title: const Text('Aggiungi brano', style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    cursorColor: Color(0xFF00FF00),
                    decoration: const InputDecoration(
                      labelText: 'Titolo',
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00FF00)),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Campo obbligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Altri artisti?', style: TextStyle(color: Colors.white)),
                      Radio<bool>(
                        activeColor: Color(0xFF00FF00),
                        value: true,
                        groupValue: altriArtistiSingolo,
                        onChanged: (val) {
                          setStateDialog(() {
                            altriArtistiSingolo = val!;
                          });
                        },
                      ),
                      const Text('Sì', style: TextStyle(color: Colors.white)),
                      Radio<bool>(
                        activeColor: Color(0xFF00FF00),
                        value: false,
                        groupValue: altriArtistiSingolo,
                        onChanged: (val) {
                          setStateDialog(() {
                            altriArtistiSingolo = val!;
                          });
                        },
                      ),
                      const Text('No', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  if (altriArtistiSingolo)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              activeColor: Color(0xFF00FF00),
                              value: 'main',
                              groupValue: tipoArtistaSingolo,
                              onChanged: (val) {
                                setStateDialog(() {
                                  tipoArtistaSingolo = val!;
                                });
                              },
                            ),
                            const Text('Main artist', style: TextStyle(color: Colors.white)),
                            Radio<String>(
                              activeColor: Color(0xFF00FF00),
                              value: 'featuring',
                              groupValue: tipoArtistaSingolo,
                              onChanged: (val) {
                                setStateDialog(() {
                                  tipoArtistaSingolo = val!;
                                });
                              },
                            ),
                            const Text('Featuring', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        TextField(
                          controller: altriArtistiControllerSingolo,
                          cursorColor: Color(0xFF00FF00),
                          decoration: const InputDecoration(
                            labelText: 'Nomi altri artisti (separati da virgola)',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF00FF00)),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField2<String>(
                          isExpanded: true,
                          value: generiSelezionati.isNotEmpty ? generiSelezionati[0] : null,
                          items: generiDisponibili.map((genere) {
                            return DropdownMenuItem(
                              value: genere,
                              child: Text(genere),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Genere principale',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF00FF00)),
                            ),
                          ),
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
                          value: generiSelezionati.length > 1 ? generiSelezionati[1] : null,
                          items: generiDisponibili.map((genere) {
                            return DropdownMenuItem(
                              value: genere,
                              child: Text(genere),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Genere secondario (opzionale)',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF00FF00)),
                            ),
                          ),
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
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                                ), 
                          onPressed: _pickAudio,
                          label: Text(_audioUrl == null ? 'Carica la traccia audio' : 'Traccia audio caricata'),
                        ),
                        ..._crediti.keys.map((key) => TextFormField(
                              cursorColor: Color(0xFF00FF00),
                              decoration: InputDecoration(
                                labelText: '$key (separati da virgola)',
                                labelStyle: TextStyle(color: Colors.white),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF00FF00)),
                                ),
                              ),
                              onChanged: (v) => _crediti[key] = v.split(',').map((e) => e.trim()).toList(),
                            )),
                  ],
                ),
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
    List<String> artistIdSingolo = [...widget.artistIds];
    if (isSingle && _altriArtistiSingolo && _altriArtistiControllerSingolo.text.isNotEmpty) {
      final nomi = _altriArtistiControllerSingolo.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      for (final nome in nomi) {
        final query = await FirebaseFirestore.instance.collection('artisti').where('nome', isEqualTo: nome).get();
        if (query.docs.isNotEmpty) {
          artistIdSingolo.add(query.docs.first.id);
        } else {
          final nuovoArtista = await FirebaseFirestore.instance.collection('artisti').add({'nome': nome});
          artistIdSingolo.add(nuovoArtista.id);
        }
      }
    }

    if (!_formKey.currentState!.validate() || _audioUrl == null || _coverUrl == null) return;
    setState(() => _loading = true);


    final cid = Uuid().v4();

    final release = {
      'addedAt': FieldValue.serverTimestamp(),
      'album': _albumController.text,
      'artistId': isSingle ? artistIdSingolo : widget.artistIds,
      'isSingle': isSingle,
      'ascoltiTotali': 0,
      'audioUrl': _audioUrl,
      'cid': cid,
      'cover': _coverUrl,
      'crediti': _crediti,
      'statPaese': {'IT': 0},
      'titolo': _titleController.text,
      'generi': generiSelezionati,
    };

    final docRef = FirebaseFirestore.instance.collection('canzoni').doc(cid);
    await docRef.set(release);

    // Se è un album, salva le tracce come subcollection 'tracks'
    if (!isSingle) {
      for (int i = 0; i < albumTracks.length; i++) {
        final track = albumTracks[i];
        await docRef.collection('tracks').add({
          ...track,
          'order': i,
        });
      }
    }

    setState(() => _loading = false);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se è un singolo, aggiorna il nome album in automatico
    if (isSingle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_albumController.text != _titleController.text) {
          _albumController.text = _titleController.text;
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi una nuova release'),
        backgroundColor: const Color.fromARGB(255, 24, 96, 26),
        ),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(16),
            child: isSingle
                ? Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          cursorColor: Color(0xFF00FF00),
                          decoration: const InputDecoration(
                            labelText: 'Titolo',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF00FF00)),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Campo obbligatorio' : null,
                        ),
                        TextFormField(
                          controller: _titleController,
                          cursorColor: Color(0xFF00FF00),
                          decoration: const InputDecoration(
                            labelText: 'Nome album',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF00FF00)),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Campo obbligatorio' : null,
                          enabled: !isSingle,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text('Altri artisti?', style: TextStyle(color: Colors.white)),
                            Radio<bool>(
                              activeColor: Color(0xFF00FF00),
                              value: true,
                              groupValue: _altriArtistiSingolo,
                              onChanged: (val) {
                                setState(() {
                                  _altriArtistiSingolo = val!;
                                });
                              },
                            ),
                            const Text('Sì', style: TextStyle(color: Colors.white)),
                            Radio<bool>(
                              activeColor: Color(0xFF00FF00),
                              value: false,
                              groupValue: _altriArtistiSingolo,
                              onChanged: (val) {
                                setState(() {
                                  _altriArtistiSingolo = val!;
                                });
                              },
                            ),
                            const Text('No', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        if (_altriArtistiSingolo)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Radio<String>(
                                    activeColor: Color(0xFF00FF00),
                                    value: 'main',
                                    groupValue: _tipoArtistaSingolo,
                                    onChanged: (val) {
                                      setState(() {
                                        _tipoArtistaSingolo = val!;
                                      });
                                    },
                                  ),
                                  const Text('Main artist', style: TextStyle(color: Colors.white)),
                                  Radio<String>(
                                    activeColor: Color(0xFF00FF00),
                                    value: 'featuring',
                                    groupValue: _tipoArtistaSingolo,
                                    onChanged: (val) {
                                      setState(() {
                                        _tipoArtistaSingolo = val!;
                                      });
                                    },
                                  ),
                                  const Text('Featuring', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              TextField(
                                controller: _altriArtistiControllerSingolo,
                                cursorColor: Color(0xFF00FF00),
                                decoration: const InputDecoration(
                                  labelText: 'Nomi altri artisti (separati da virgola)',
                                  labelStyle: TextStyle(color: Colors.white),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF00FF00)),
                                  ),
                                  ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField2<String>(
                          isExpanded: true,
                          value: generiSelezionati.isNotEmpty ? generiSelezionati[0] : null,
                          items: generiDisponibili.map((genere) {
                            return DropdownMenuItem(
                              value: genere,
                              child: Text(genere),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Genere principale',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF00FF00)),
                            ),
                          ),
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
                          value: generiSelezionati.length > 1 ? generiSelezionati[1] : null,
                          items: generiDisponibili.map((genere) {
                            return DropdownMenuItem(
                              value: genere,
                              child: Text(genere),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Genere secondario (opzionale)',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF00FF00)),
                            ),
                          ),
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
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                                ), 
                          onPressed: _pickAudio,
                          label: Text(_audioUrl == null ? 'Carica la release' : 'Release caricata'),
                        ),
                        ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                                ),
                          onPressed: _pickCover,
                          label: Text(_coverUrl == null ? 'Carica la cover' : 'Cover caricata'),
                        ),
                        const SizedBox(height: 16),
                        ..._crediti.keys.map((key) => TextFormField(
                              cursorColor: Color(0xFF00FF00),
                              decoration: InputDecoration(
                                labelText: '$key (separati da virgola)',
                                labelStyle: TextStyle(color: Colors.white),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF00FF00)),
                                ),
                              ),
                              onChanged: (v) => _crediti[key] = v.split(',').map((e) => e.trim()).toList(),
                            )),
                        const SizedBox(height: 24),
                        _loading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                                ), 
                                onPressed: _submit,
                                label: const Text('Invia'),
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
                      const Text(
                        'Aggiungi informazioni dell\'album',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _albumController,
                        cursorColor: Color(0xFF00FF00),
                        decoration: const InputDecoration(
                          labelText: 'Nome album',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Campo obbligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField2<String>(
                        isExpanded: true,
                        value: generiSelezionati.isNotEmpty ? generiSelezionati[0] : null,
                        items: generiDisponibili.map((genere) {
                          return DropdownMenuItem(
                            value: genere,
                            child: Text(genere),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Genere principale',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                        ),
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
                          offset: const Offset(0, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField2<String>(
                        value: generiSelezionati.length > 1 ? generiSelezionati[1] : null,
                        items: generiDisponibili.map((genere) {
                          return DropdownMenuItem(
                            value: genere,
                            child: Text(genere),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Genere secondario (opzionale)',
                          labelStyle: TextStyle(color: Colors.white),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00FF00)),
                          ),
                        ),
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
                          offset: const Offset(0, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                        ),
                        onPressed: _pickCover,
                        label: Text(_coverUrl == null ? 'Carica la cover' : 'Cover caricata'),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white),
                      const SizedBox(height: 12),
                      const Text(
                        'Carica i brani',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _addTrack,
                        icon: const Icon(Icons.add),
                        label: const Text('Aggiungi'),
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
                                      trailing: ElevatedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Modifica'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        ),
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              final titleController = TextEditingController(text: track['titolo'] ?? '');
                                              String? audioUrl = track['audioUrl'];
                                              String? coverUrl = track['cover'];
                                              List<String> trackGeneri = List<String>.from(track['generi'] ?? []);
                                              // Crediti
                                              Map<String, List<String>> crediti = {
                                                'Autore': List<String>.from(track['Autore'] ?? []),
                                                'Compositore': List<String>.from(track['Compositore'] ?? []),
                                                'Producer': List<String>.from(track['Producer'] ?? []),
                                              };
                                              // Altri artisti
                                              bool altriArtisti = track['altriArtisti'] ?? false;
                                              String tipoArtista = track['tipoArtista'] ?? 'featuring';
                                              final TextEditingController altriArtistiController = TextEditingController(text: (track['nomiAltriArtisti'] ?? '').toString());
                                              return StatefulBuilder(
                                                builder: (context, setStateDialog) {
                                                  return AlertDialog(
                                                    backgroundColor: Colors.green[900],
                                                    title: const Text('Modifica brano', style: TextStyle(color: Colors.white)),
                                                    content: SizedBox(
                                                      width: 600,
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            TextFormField(
                                                              controller: titleController,
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
                                                            Row(
                                                              children: [
                                                                const Text('Altri artisti?', style: TextStyle(color: Colors.white)),
                                                                Radio<bool>(
                                                                  activeColor: Color(0xFF00FF00),
                                                                  value: true,
                                                                  groupValue: altriArtisti,
                                                                  onChanged: (val) {
                                                                    setStateDialog(() {
                                                                      altriArtisti = val!;
                                                                    });
                                                                  },
                                                                ),
                                                                const Text('Sì', style: TextStyle(color: Colors.white)),
                                                                Radio<bool>(
                                                                  activeColor: Color(0xFF00FF00),
                                                                  value: false,
                                                                  groupValue: altriArtisti,
                                                                  onChanged: (val) {
                                                                    setStateDialog(() {
                                                                      altriArtisti = val!;
                                                                    });
                                                                  },
                                                                ),
                                                                const Text('No', style: TextStyle(color: Colors.white)),
                                                              ],
                                                            ),
                                                            if (altriArtisti)
                                                              Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Radio<String>(
                                                                        activeColor: Color(0xFF00FF00),
                                                                        value: 'main',
                                                                        groupValue: tipoArtista,
                                                                        onChanged: (val) {
                                                                          setStateDialog(() {
                                                                            tipoArtista = val!;
                                                                          });
                                                                        },
                                                                      ),
                                                                      const Text('Main artist', style: TextStyle(color: Colors.white)),
                                                                      Radio<String>(
                                                                        activeColor: Color(0xFF00FF00),
                                                                        value: 'featuring',
                                                                        groupValue: tipoArtista,
                                                                        onChanged: (val) {
                                                                          setStateDialog(() {
                                                                            tipoArtista = val!;
                                                                          });
                                                                        },
                                                                      ),
                                                                      const Text('Featuring', style: TextStyle(color: Colors.white)),
                                                                    ],
                                                                  ),
                                                                  TextField(
                                                                    controller: altriArtistiController,
                                                                    cursorColor: Color(0xFF00FF00),
                                                                    decoration: const InputDecoration(
                                                                      labelText: 'Nomi altri artisti (separati da virgola)',
                                                                      labelStyle: TextStyle(color: Colors.white),
                                                                      focusedBorder: UnderlineInputBorder(
                                                                        borderSide: BorderSide(color: Color(0xFF00FF00)),
                                                                      ),
                                                                    ),
                                                                    style: const TextStyle(color: Colors.white),
                                                                  ),
                                                                ],
                                                              ),
                                                            const SizedBox(height: 12),
                                                            DropdownButtonFormField2<String>(
                                                              isExpanded: true,
                                                              value: trackGeneri.isNotEmpty ? trackGeneri[0] : null,
                                                              items: generiDisponibili.map((genere) {
                                                                return DropdownMenuItem(
                                                                  value: genere,
                                                                  child: Text(genere),
                                                                );
                                                              }).toList(),
                                                              decoration: const InputDecoration(
                                                                labelText: 'Genere principale',
                                                                labelStyle: TextStyle(color: Colors.white),
                                                                focusedBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(color: Color(0xFF00FF00)),
                                                                ),
                                                              ),
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
                                                            DropdownButtonFormField2<String>(
                                                              value: trackGeneri.length > 1 ? trackGeneri[1] : null,
                                                              items: generiDisponibili.map((genere) {
                                                                return DropdownMenuItem(
                                                                  value: genere,
                                                                  child: Text(genere),
                                                                );
                                                              }).toList(),
                                                              decoration: const InputDecoration(
                                                                labelText: 'Genere secondario (opzionale)',
                                                                labelStyle: TextStyle(color: Colors.white),
                                                                focusedBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(color: Color(0xFF00FF00)),
                                                                ),
                                                              ),
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
                                                            ElevatedButton.icon(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.green[700],
                                                                foregroundColor: Colors.white,
                                                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                                                              ),
                                                              onPressed: () async {
                                                                final result = await FilePicker.platform.pickFiles(
                                                                  type: FileType.custom,
                                                                  allowedExtensions: ['mp3', 'wav'],
                                                                );
                                                                if (result != null && result.files.single.path != null) {
                                                                  final filePath = result.files.single.path!;
                                                                  final url = await _uploadFile(filePath, 'music');
                                                                  setStateDialog(() {
                                                                    audioUrl = url;
                                                                  });
                                                                }
                                                              },
                                                              label: Text(audioUrl == null ? 'Carica traccia audio' : 'Traccia audio caricata'),
                                                            ),
                                                            const SizedBox(height: 12),
                                                            ...crediti.keys.map((key) => TextFormField(
                                                                  cursorColor: Color(0xFF00FF00),
                                                                  decoration: InputDecoration(
                                                                    labelText: '$key (separati da virgola)',
                                                                    labelStyle: TextStyle(color: Colors.white),
                                                                    focusedBorder: UnderlineInputBorder(
                                                                      borderSide: BorderSide(color: Color(0xFF00FF00)),
                                                                    ),
                                                                  ),
                                                                  initialValue: crediti[key]?.join(', '),
                                                                  onChanged: (v) => crediti[key] = v.split(',').map((e) => e.trim()).toList(),
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          albumTracks[index] = {
                                                            'titolo': titleController.text,
                                                            'audioUrl': audioUrl,
                                                            'cover': coverUrl,
                                                            'generi': List<String>.from(trackGeneri),
                                                            'Autore': crediti['Autore'],
                                                            'Compositore': crediti['Compositore'],
                                                            'Producer': crediti['Producer'],
                                                            'altriArtisti': altriArtisti,
                                                            'tipoArtista': tipoArtista,
                                                            'nomiAltriArtisti': altriArtistiController.text,
                                                          };
                                                          setState(() {});
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text('Salva', style: TextStyle(color: Colors.white)),
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
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                        ),
                        onPressed: _submit,
                        label: const Text('Carica album'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 4, 35, 5),
        );
    }
  }