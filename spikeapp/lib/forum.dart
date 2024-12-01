import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart';
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
      // Initial fetch of posts
      final records = await pb.collection('forum').getFullList();
      setState(() {
        _posts = records.map((record) => record.toJson()).toList();
        _isLoading = false;
      });
    } catch (e) {
      // Fehlerbehandlung hier
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching posts: $e');
      }
    }
  }

  void _subscribeToRealTimeUpdates() {
    // Subscribe to changes in any forum record
    pb.collection('forum').subscribe('*', (e) {
      setState(() {
        if (e.action == 'create') {
          _posts.add(e.record?.toJson() ?? {});
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
    // Unsubscribe from all real-time updates
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
            ? Center(
                child: SpinKitFadingCircle(color: Colors.deepPurple),
              )
            : ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: post['image'] != null
                          ? Image.network(post['image'])
                          : Icon(Icons.account_circle, color: Colors.deepPurpleAccent),
                      title: Text(
                        post['title'] ?? 'No Title',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['content'] ?? 'No Content',
                            style: TextStyle(color: Colors.white70),
                          ),
                          if (post['file'] != null)
                            Text(
                              'Attachment: ${post['file']}',
                              style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                            ),
                        ],
                      ),
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
  final PocketBase pb = PocketBase('https://spikestone.site');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;
  File? _image;
  File? _file;

  final ImagePicker _picker = ImagePicker();

  void _addPost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<http.MultipartFile> files = [];

      if (_image != null) {
        files.add(
          http.MultipartFile.fromBytes(
            'documents',
            await _image!.readAsBytes(),
            filename: _image!.path.split('/').last,
          ),
        );
      }

      if (_file != null) {
        files.add(
          http.MultipartFile.fromBytes(
            'documents',
            await _file!.readAsBytes(),
            filename: _file!.path.split('/').last,
          ),
        );
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
      // Fehlerbehandlung hier
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error adding post: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.text_snippet),
                  ),
                  maxLines: 5,
                ),
                SizedBox(height: 20),
                _image != null
                    ? Image.file(_image!)
                    : ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Pick Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                _file != null
                    ? Text('File selected')
                    : ElevatedButton(
                        onPressed: _pickFile,
                        child: Text('Pick File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                _isLoading
                    ? SpinKitFadingCircle(color: Colors.deepPurple)
                    : ElevatedButton(
                        onPressed: _addPost,
                        child: Text('Add Post'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
