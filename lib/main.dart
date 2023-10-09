// import 'dart:convert';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:tflite_v2/tflite_v2.dart';

import 'package:camera/camera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.tealAccent),
      home: ImagePickerDemo(),
    );
  }
}

class ImagePickerDemo extends StatefulWidget {
  const ImagePickerDemo({super.key});

  @override
  _ImagePickerDemoState createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";
  var vAux;
  var vAux2;
  List<Map<String, dynamic>> auxiliarList = [];
  var dataList = [];
  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/modelo-treinado.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      detectimage(file!);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future detectimage(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
      asynch: true,
    );
    setState(() {
      _recognitions = recognitions;
      v = recognitions.toString();

      vAux = recognitions?[0]["label"].toString().split(" ")[1].toUpperCase();
      vAux2 = (recognitions?[0]["confidence"] * 100).toStringAsFixed(2);
      // dataList = List<Map<String, dynamic>>.from(jsonDecode(v));
    });
    print("//////////////////////////////////////////////////");
    print(_recognitions);
    // print(dataList);
    print("//////////////////////////////////////////////////");
    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _image = image;
          file = File(image.path);
        });
        detectimage(file!);
      } else {
        // Handle the case where the user canceled taking a picture.
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classificador de Imagens'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              )
            else
              Column(
                children: [
                  Lottie.asset(
                    'assets/lottie/bichinhopulando.json',
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                  const Text('Nenhuma imagem selecionada'),
                ],
              ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size(250, 60)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.teal),
                        shadowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.black.withOpacity(0.6)),
                        elevation: MaterialStateProperty.all<double>(4),
                      ),
                      onPressed: _pickImage,
                      child: const Text(
                        'Abrir Galeria',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size(250, 60)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.teal),
                        shadowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.black.withOpacity(0.6)),
                        elevation: MaterialStateProperty.all<double>(4),
                      ),
                      onPressed: _takePicture,
                      child: const Text(
                        'Tirar Foto',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            (vAux == null)
                ? const Text(
                    "Nenhum objeto detectado",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  )
                : RichText(
                    text: TextSpan(
                      text: '$vAux Detectado! ',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '\n $vAux2% de certeza',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
          ],
        ),
      ),
    );
  }
}
