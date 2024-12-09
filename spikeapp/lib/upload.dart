import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';

class MultipleFileUpload extends StatefulWidget {
  @override
  _MultipleFileUploadState createState() => _MultipleFileUploadState();
}

class _MultipleFileUploadState extends State<MultipleFileUpload> {
  final pb = PocketBase('https://spikestone.site');
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  XFile? _file1;
  XFile? _file2;
  double _uploadProgress = 0;

  Future<void> _pickImage(int fileNumber) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (fileNumber == 1) {
        _file1 = pickedFile;
      } else {
        _file2 = pickedFile;
      }
    });
  }

  Future<void> _uploadFile(XFile file, String fieldName) async {
    final request = http.MultipartRequest('POST', Uri.parse('https://spikestone.site/api/collections/example'));
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    RequestFocusAction(event) {
      setState(() {
        _uploadProgress = event.cumulativeBytesLoaded / event.contentLength;
      });
    };

    final response = await request.send();
    if (response.statusCode == 200) {
      // Handle successful upload
      print('File uploaded successfully');
    } else {
      // Handle error
      print('Upload failed: ${response.statusCode}');
    }
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate() && _file1 != null && _file2 != null) {
      // Create a new record with the title and uploaded files
      final record = await pb.collection('example').create(
        body: {
          'title': _titleController.text,
        },
        files: [
          await http.MultipartFile.fromPath('documents', _file1!.path),
          await http.MultipartFile.fromPath('documents', _file2!.path),
        ],
      );
      print('Record created: ${record.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mehrere Dateien hochladen')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Textfeld für den Titel
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Titel'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib einen Titel ein';
                }
                return null;
              },
            ),
            // Buttons zum Auswählen der Dateien
            ElevatedButton(
              onPressed: () => _pickImage(1),
              child: Text('Datei 1 auswählen'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(2),
              child: Text('Datei 2 auswählen'),
            ),
            // Fortschrittsbalken
            LinearProgressIndicator(value: _uploadProgress),
            // Button zum Hochladen
            ElevatedButton(
              onPressed: _onSubmit,
              child: Text('Hochladen'),
            ),
          ],
        ),
      ),
    );
  }
}