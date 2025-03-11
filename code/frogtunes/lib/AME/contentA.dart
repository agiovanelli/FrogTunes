import 'package:flutter/material.dart';

class HomeAContent extends StatelessWidget {
  const HomeAContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Center(
                      child: Text('Ultime canzoni ascoltate',
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
              Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Center(
                      child: Text('Le tue playlist',
                          style:
                              TextStyle(fontSize: 26, color: Colors.white)))),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }
}
