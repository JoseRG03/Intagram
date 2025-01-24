import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intec_social_app/controllers/posts-controller.dart';
import 'package:intec_social_app/controllers/user-controller.dart';

class PostStoryScreen extends StatefulWidget {

  const PostStoryScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PostStoryScreen> createState() => _PostStoryScreenState();
}

class _PostStoryScreenState extends State<PostStoryScreen> {
  UserController userController = UserController();
  PostsController postsController = PostsController();

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _postStory() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl = await postsController.uploadImage(_selectedImage!);
      if (imageUrl == null) throw Exception("Image upload failed");

      await postsController.saveStory(imageUrl);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Story posted successfully!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post story: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Story")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedImage != null)
              Image.file(_selectedImage!)
            else
              const Placeholder(fallbackHeight: 200),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text("Pick Image from Gallery"),
            ),
            ElevatedButton(
              onPressed: _isUploading ? null : _postStory,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text("Post Story"),
            ),
          ],
        ),
      ),
    );
  }
}
