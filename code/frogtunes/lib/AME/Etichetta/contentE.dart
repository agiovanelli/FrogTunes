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
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text('I tuoi Manager',
                        style: TextStyle(fontSize: 26, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const ListTile(
                leading: Icon(Icons.person_2_sharp, color: Colors.white),
                title: Text('Lorenzo', style: TextStyle(color: Colors.white)),
              ),
              const ListTile(
                leading: Icon(Icons.person_2_sharp, color: Colors.white),
                title: Text('Andrea', style: TextStyle(color: Colors.white)),
              ),
              const ListTile(
                leading: Icon(Icons.person_2_sharp, color: Colors.white),
                title: Text('Matteo', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 50),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text('I tuoi artisti',
                        style: TextStyle(fontSize: 26, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const ListTile(
                leading: Icon(Icons.person_2_sharp, color: Colors.white),
                title:
                    Text('Narcolessia', style: TextStyle(color: Colors.white)),
              ),
              const ListTile(
                leading: Icon(Icons.person_2_sharp, color: Colors.white),
                title: Text('Marco444', style: TextStyle(color: Colors.white)),
              ),
              const ListTile(
                leading: Icon(Icons.person_2_sharp, color: Colors.white),
                title:
                    Text('AleXX iSt4R', style: TextStyle(color: Colors.white)),
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
