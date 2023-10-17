import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nasa_app/home_page.dart';
import 'package:nasa_app/info_img.dart';

class DataImages extends StatefulWidget {
  final String subjectKey;

  const DataImages({Key? key, required this.subjectKey});

  @override
  _DataImagesState createState() => _DataImagesState();
}

class _DataImagesState extends State<DataImages> {
  final String apiKey = 's4LlibG2uWAaRbhYx8vL5XCLXH8CSDUw7imyvIf3';

  Future<List<dynamic>> fetchImages() async {
    final response = await http.get(
      Uri.parse('https://images-api.nasa.gov/search?q=${widget.subjectKey}&media_type=image'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['collection']['items'];
    } else {
      throw Exception('Error al cargar las imágenes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 210, 238, 252),
          title: const Text('NASA Image Library', style: TextStyle(color: Colors.black)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          )
        ),
        body: Center(
          child: FutureBuilder<List<dynamic>>(
            future: fetchImages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => InfoImg(data: index, subjectKey: widget.subjectKey)),
                            );
                          },
                          child: ListTile(
                            title: Text(snapshot.data?[index]['data'][0]['title']),
                            leading: Image.network(
                              snapshot.data?[index]['links'][0]['href'],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.black,
                          height: 20,
                          thickness: 1,
                          indent: 10,
                          endIndent: 10,
                        ),
                      ],
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
