import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:nasa_app/data_images.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class InfoImg extends StatefulWidget {
  final dynamic data;
  final String subjectKey;
  const InfoImg({Key? key, required this.data, required this.subjectKey});

  @override
  _InfoImgState createState() => _InfoImgState();
}

class _InfoImgState extends State<InfoImg> {
  late List<dynamic> images; // Almacena la lista de imágenes

  @override
  void initState() {
    super.initState();
    images = [];
    fetchImages(); // Llama a la función para obtener imágenes cuando se inicializa el widget
  }

  Future<void> fetchImages() async {
    final response = await http.get(
      Uri.parse('https://images-api.nasa.gov/search?q=${widget.subjectKey}&media_type=image'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      images = data['collection']['items'];
    } else {
      throw Exception('Error al cargar las imágenes');
    }
    if (mounted) {
      setState(() {}); // Actualiza el estado para reflejar las imágenes descargadas
    }
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final imageUrl = images[widget.data]['links'][0]['href'] ?? '';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(imageUrl, fit: BoxFit.cover, height: 600,),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 90.0, top: 50.0, left: 10.0),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 199, 245, 244), size: 40),
                        onPressed: () {
                          // Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DataImages(subjectKey: widget.subjectKey,)));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, top: 60.0, right: 10.0),
                      child: Column(
                        children: [
                          Text(
                            images[widget.data]['data'][0]['date_created'],
                            style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 199, 245, 244), fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () async{
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Permission to access storage'),
                                  content: const Text('This app needs permission to access your storage in order to download the image.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () async {
                                        await checkAndRequestPermission(false);
                                        Navigator.pop(context, 'Cancel');
                                      }, 
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async{
                                        Navigator.pop(context, 'OK');
                                        await checkAndRequestPermission(true);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }, 
                            icon: const Icon(Icons.downloading_outlined, color: Color.fromARGB(255, 199, 245, 244), size: 40,)),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: 500,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: InfoStars(data: images[widget.data]['data'][0]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> checkAndRequestPermission(bool isGranted) async {
    var status = isGranted ? PermissionStatus.granted : await Permission.storage.status;

    if (status.isGranted) {
      await downloadImage(images[widget.data]['links'][0]['href']);
    } else {
      // Muestra un cuadro de diálogo con el mensaje "Permisos Denegados"
      Flushbar(
        title: 'Permission denied',
        message: 'The permission to access the storage was denied.',
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  Future<void> downloadImage(String imageUrl) async {
    final file = await DefaultCacheManager().getSingleFile(imageUrl);

    // ignore: unnecessary_null_comparison
    if (file != null) {
      final localPathVar = await localPath;
      final fileName = 'nasa_image.png'; // Reemplaza con el nombre que desees
      final newPath = '$localPathVar/$fileName';

      try {
        await file.copy(newPath); // Copia el archivo descargado a la ubicación local deseada

        // Guardar la imagen en la galería del dispositivo
        final result = await ImageGallerySaver.saveFile(newPath);

        if (result != null && result['isSuccess']) {
          // La imagen se guardó con éxito en la galería
          Flushbar(
            title: 'Download complete',
            message: 'The image was saved successfully in the gallery.',
            duration: Duration(seconds: 3),
          )..show(context);
        } else {
          Flushbar(
            title: 'Error when saving image in gallery',
            message: 'There was a problem saving the image in the gallery.',
            duration: Duration(seconds: 3),
          )..show(context);
        }
      } catch (e) {
        // Maneja cualquier excepción que pueda ocurrir al copiar o guardar la imagen
        Flushbar(
          title: 'Error of download',
          message: 'There was a problem downloading the image.',
          duration: Duration(seconds: 3),
        )..show(context);
      }
    } else {
      Flushbar(
        title: 'Error of download',
        message: 'There was a problem downloading the image.',
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }


}

class InfoStars extends StatelessWidget {
  final dynamic data;

  const InfoStars({
    Key? key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [ClipRRect(
        borderRadius: BorderRadius.circular(45.0),
        child: Card(
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(data['title'], style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                subtitle: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text('Center: ${data['center']}', style: TextStyle(fontSize: 20, color: Colors.blue),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text('Nasa ID: ${data['nasa_id']?.isNotEmpty == true ? data['nasa_id'] : 'XXX'}', style: TextStyle(fontSize: 20),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text('Location: ${data['location'] != null ? data['location'] : 'UNKNOWN'}', style: TextStyle(fontSize: 20),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(data['description'].replaceAll(RegExp(r'(https?://\S+|<a\s*href[^>]*>)'), ''), style: TextStyle(fontSize: 20),),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ],
    );
  }
}
