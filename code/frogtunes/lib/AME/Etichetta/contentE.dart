import 'package:flutter/material.dart';

class HomeEContent extends StatelessWidget {
  const HomeEContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Allinea il container a sinistra
                children: [
                  Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(
                        child: Text('Singoli',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: const Center(
                          child: Text('Album',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white)))),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Allinea il container a sinistra
                  children: [
                    Text('16',
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                    Text('2',
                        style: TextStyle(fontSize: 15, color: Colors.white))
                  ]),
              const SizedBox(height: 50),
              Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Center(
                      child: Text('Le tue ultime release',
                          style:
                              TextStyle(fontSize: 26, color: Colors.white)))),
              const ListTile(
                leading: Icon(Icons.music_note, color: Colors.white),
                title: Text('bambino indaco',
                    style: TextStyle(color: Colors.white)),
                subtitle:
                    Text('Narcolessia', style: TextStyle(color: Colors.grey)),
              ),
              const ListTile(
                leading: Icon(Icons.music_note, color: Colors.white),
                title: Text('Voragine', style: TextStyle(color: Colors.white)),
                subtitle:
                    Text('Marco444', style: TextStyle(color: Colors.grey)),
              ),
              const ListTile(
                leading: Icon(Icons.music_note, color: Colors.white),
                title:
                    Text('micixsempre', style: TextStyle(color: Colors.white)),
                subtitle:
                    Text('Narcolessia', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
