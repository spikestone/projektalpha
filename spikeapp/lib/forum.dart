import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'global.dart' as global;

class ForumPage extends StatefulWidget {
  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final PocketBase pb = global.pb;
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _subscribeToRealTimeUpdates();
  }

  void _fetchPosts() async {
    try {
      final records = await pb.collection('forum').getFullList();
      setState(() {
        _posts = records.map((record) => record.toJson()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching posts: $e');
      }
    }
  }

  void _subscribeToRealTimeUpdates() {
    pb.collection('forum').subscribe('*', (e) {
      setState(() {
        if (e.action == 'create') {
          _posts.insert(0, e.record?.toJson() ?? {});
        } else if (e.action == 'update') {
          final index = _posts.indexWhere((post) => post['id'] == e.record?.id);
          if (index != -1) {
            _posts[index] = e.record?.toJson() ?? {};
          }
        } else if (e.action == 'delete') {
          _posts.removeWhere((post) => post['id'] == e.record?.id);
        }
      });
    });
  }

  void _navigateToAddPost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPostPage(onPostAdded: _fetchPosts)),
    );
  }

  @override
  void dispose() {
    pb.collection('forum').unsubscribe('*');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToAddPost,
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[900],
        child: _isLoading
            ? Center(child: SpinKitFadingCircle(color: Colors.deepPurple))
            : ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    color: Colors.black,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: post['image'] != null
                          ? Image.network(
                              pb.baseUrl + '/api/files/forum/' + post['id'] + '/' + post['image'],
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image, color: Colors.deepPurpleAccent, size: 50),
                      title: Text(
                        post['title'] ?? 'No Title',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        post['content'] ?? 'No Content',
                        style: TextStyle(color: Colors.white70),
                      ),
                      
                      trailing: Icon(Icons.message, color: Colors.deepPurple),
                      onTap: () {
                        
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class AddPostPage extends StatefulWidget {
  final Function onPostAdded;

  AddPostPage({required this.onPostAdded});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final PocketBase pb = global.pb;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  XFile? _image;
  Uint8List? _imageBytes; // Für Webbrowser
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (kIsWeb) {
          // Web: Lade die Datei als Bytes
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _image = pickedFile;
            _imageBytes = bytes;
          });
        } else {
          // Andere Plattformen: Nutze den Dateipfad
          setState(() {
            _image = pickedFile;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _addPost() async {
   /* if (_titleController.text.isEmpty || (_image == null && _imageBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte Titel und Bild auswählen')),
      );
      return;
    } */

    setState(() {
      _isLoading = true;
    });

    try {
      var files = <http.MultipartFile>[];

      if (_image != null) {
        if (kIsWeb) {
          // Web: Datei über Bytes hochladen
          files.add(http.MultipartFile.fromBytes(
            'image',
            _imageBytes!,
            filename: _image!.name,
          ));
        } else {
          // Andere Plattformen: Datei über den Pfad hochladen
          files.add(await http.MultipartFile.fromPath('image', _image!.path));
        }
      }

      await pb.collection('forum').create(
        body: {
          'title': _titleController.text,
          'content': _contentController.text,
        },
        files: files,
      );

      widget.onPostAdded();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Hochladen: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.text_snippet),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            _imageBytes != null || _image != null
                ? (kIsWeb
                    ? Image.memory(_imageBytes!, height: 150)
                    : Image.file(File(_image!.path), height: 150))
                : ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addPost,
                    child: Text('Add Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}