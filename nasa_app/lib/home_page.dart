import 'package:flutter/material.dart';
import 'package:nasa_app/data_images.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> subjects = [
    {'key': 'stars', 'value': 'Stars'},
    {'key': 'galaxy', 'value': 'Galaxy'},
    {'key': 'planets', 'value': 'Planets'},
    {'key': 'apollo', 'value': 'Apollo'},
    {'key': 'earth', 'value': 'Earth'},
    {'key': 'comets', 'value': 'Comets'},
    {'key': 'asteroids', 'value': 'Asteroids'},
    {'key': 'cosmic', 'value': 'Cosmic'},
    {'key': 'moon', 'value': 'Moon'},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Image.asset('assets/Nasa.jpg', fit: BoxFit.cover, height: 500),
            const SizedBox(height: 20),
            Text('Choose a subject to see', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
            Expanded(
              child: ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10), // Espacio vertical entre elementos
                    color: Color.fromARGB(255, 210, 238, 252),
                    child: ListTile(
                      // title: ElevatedButton(child: ),
                      title: Text(subject['value']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      // Puedes navegar a una página relacionada con el tema cuando se toca el elemento de la lista.
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DataImages(subjectKey: subject['key']!)));
                        // Implementa la navegación a la página deseada aquí.
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
