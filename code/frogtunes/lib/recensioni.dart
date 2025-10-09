import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class RecensioniPage extends StatefulWidget {
  final String songId;
  final String titolo;
  final bool editable;

  const RecensioniPage({
    super.key,
    required this.songId,
    required this.titolo,
    this.editable = false,
  });

  @override
  State<RecensioniPage> createState() => _RecensioniPageState();
}

class _RecensioniPageState extends State<RecensioniPage> {
  // Controller per la risposta
  final Map<String, TextEditingController> _replyControllers = {};
  final TextEditingController _controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  // Funzione per aggiungere una recensione al database
  Future<void> _aggiungiRecensione() async {
    if (_controller.text.trim().isEmpty || user == null) return;

    final songRef = FirebaseFirestore.instance
        .collection('recensioni')
        .doc(widget.songId);

    final reviewRef = songRef
        .collection('recUtenti')
        .doc(user!.uid);

    await reviewRef.set({
      'uid': user!.uid,
      'autore': user!.displayName ?? user!.email,
      'testo': _controller.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); 

    await songRef.set({
      'cid': widget.songId,
      'ultimoAggiornamento': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _controller.clear();
  }

  // Funzione per eliminare una recensione dal database
  Future<void> _eliminaRecensione(String uid) async {
    await FirebaseFirestore.instance.collection('recensioni').doc(widget.songId).collection('recUtenti').doc(uid).delete();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Recensioni di ' + widget.titolo),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('recensioni')
                    .doc(widget.songId)
                    .collection('recUtenti')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Errore di caricamento'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text('Nessuna recensione.'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final testo = doc['testo'] ?? '';
                      final autore = doc['autore'] ?? '';
                      final isMine = user != null && doc['uid'] == user!.uid;
                      final recensioneId = doc.id;
                      _replyControllers.putIfAbsent(recensioneId, () => TextEditingController());
                      return Card(
                        color: const Color.fromARGB(255, 52, 146, 68),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  testo,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                subtitle: Text(
                                  'di $autore',
                                  style: const TextStyle(fontSize: 12, color: Colors.black),
                                ),
                                trailing: isMine
                                    ? IconButton(
                                        icon: Icon(Icons.delete, color: const Color.fromARGB(255, 170, 73, 66)),
                                        onPressed: () async{
                                          final conferma = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Elimina recensione'),
                                              content: const Text('Sei sicuro di voler eliminare questa recensione?'),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Annulla'),
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  child: const Text('Elimina'),
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (conferma == true) {
                                            await _eliminaRecensione(doc.id);
                                          }
                                        },
                                      )
                                    : null,
                              ),
                              // Risposta artista: solo una per recensione, può modificare o eliminare
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                  .collection('recensioni')
                                  .doc(widget.songId)
                                  .collection('recUtenti')
                                  .doc(recensioneId)
                                  .collection('risposte')
                                  .limit(1)
                                  .snapshots(),
                                builder: (context, replySnapshot) {
                                  if (replySnapshot.hasError) {
                                    return const Text('Errore nel caricamento risposta');
                                  }
                                  if (!replySnapshot.hasData) {
                                    return const SizedBox();
                                  }
                                  final replyDocs = replySnapshot.data!.docs;
                                  final hasReply = replyDocs.isNotEmpty;
                                  if (hasReply) {
                                    final replyDoc = replyDocs.first;
                                    final replyText = replyDoc['testo'] ?? '';
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (widget.editable) ...[
                                          Text('La tua risposta:', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(replyText, style: const TextStyle(fontSize: 15)),
                                        ] else ...[
                                          Text('Risposta di ${replyDoc['autore']}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(replyText, style: const TextStyle(fontSize: 15)),
                                        ],
                                      if (widget.editable)
                                        Row(
                                          children: [
                                            Expanded(                                              
                                              child: TextField(
                                                controller: _replyControllers[recensioneId],
                                                cursorColor: Colors.green,
                                                maxLength: 300,
                                                decoration: const InputDecoration(
                                                  labelText: 'Modifica risposta',
                                                  labelStyle: TextStyle(color: Colors.green),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                    borderSide: BorderSide(color: Colors.green),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                    borderSide: BorderSide(color: Colors.green),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                    borderSide: BorderSide(color: Colors.green, width: 2),
                                                  ),
                                                  counterStyle: TextStyle(color: Colors.white, fontSize: 12),
                                                ),
                                                style: const TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () async {
                                                final newText = _replyControllers[recensioneId]?.text.trim() ?? '';
                                                if (newText.isEmpty) return;
                                                await FirebaseFirestore.instance
                                                  .collection('recensioni')
                                                  .doc(widget.songId)
                                                  .collection('recUtenti')
                                                  .doc(recensioneId)
                                                  .collection('risposte')
                                                  .doc(replyDoc.id)
                                                  .update({
                                                    'testo': newText,
                                                    'timestamp': FieldValue.serverTimestamp(),
                                                  });
                                                _replyControllers[recensioneId]?.clear();
                                              },
                                              child: const Text('Modifica'),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                  .collection('recensioni')
                                                  .doc(widget.songId)
                                                  .collection('recUtenti')
                                                  .doc(recensioneId)
                                                  .collection('risposte')
                                                  .doc(replyDoc.id)
                                                  .delete();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Row(
                                      children: [
                                        if (widget.editable)
                                        Expanded(
                                          child: TextField(
                                            controller: _replyControllers[recensioneId],
                                            cursorColor: Colors.green,
                                            maxLength: 300,
                                            decoration: const InputDecoration(
                                              labelText: 'Rispondi',
                                              labelStyle: TextStyle(color: Colors.green),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                borderSide: BorderSide(color: Colors.green),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                borderSide: BorderSide(color: Colors.green),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                                borderSide: BorderSide(color: Colors.green, width: 2),
                                              ),
                                              counterStyle: TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (widget.editable)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () async {
                                            final replyText = _replyControllers[recensioneId]?.text.trim() ?? '';
                                            if (replyText.isEmpty || user == null) return;
                                            await FirebaseFirestore.instance
                                              .collection('recensioni')
                                              .doc(widget.songId)
                                              .collection('recUtenti')
                                              .doc(recensioneId)
                                              .collection('risposte')
                                              .add({
                                                'uid': user!.uid,
                                                'autore': user!.displayName ?? user!.email,
                                                'testo': replyText,
                                                'timestamp': FieldValue.serverTimestamp(),
                                              });
                                            _replyControllers[recensioneId]?.clear();
                                          },
                                          child: const Text('Invia'),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),  
            if (!widget.editable)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recensioni')
                  .doc(widget.songId)
                  .collection('recUtenti')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snap) {
                final esiste = snap.data?.exists ?? false;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        cursorColor: Colors.green,
                        maxLength: 300,
                        decoration: InputDecoration(
                          labelText: esiste ? 'Modifica la tua recensione' : 'Scrivi una recensione',
                          labelStyle: TextStyle(color: Colors.green),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: Colors.green, width: 2),
                          ),
                          counterStyle: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _aggiungiRecensione,
                      child: Text(esiste ? 'Modifica' : 'Invia'),
                    ),
                  ],
                ),
              );
              },
            ),
          ],
        ),
      ),
      ),
      backgroundColor: const Color.fromARGB(255, 4, 35, 5),
    );
  }
}
