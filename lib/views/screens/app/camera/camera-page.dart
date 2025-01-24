import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../controllers/posts-controller.dart';

class UploadPostScreen extends StatefulWidget {
  const UploadPostScreen({Key? key}) : super(key: key);

  @override
  State<UploadPostScreen> createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  final PostsController _postsController = PostsController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  /// Pick an image from the gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  /// Handle the upload and save process
  Future<void> _uploadPost() async {
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
      // Upload the image and get the URL
      final imageUrl = await _postsController.uploadImage(_selectedImage!);
      if (imageUrl == null) throw Exception("Image upload failed");

      // Save the post to Firestore
      await _postsController.savePost(imageUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post uploaded successfully!")),
      );

      // Clear the selected image after successful upload
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload post: $e")),
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
      appBar: AppBar(
        title: const Text("Upload Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image Preview
            if (_selectedImage != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text("No image selected"),
                ),
              ),
            const SizedBox(height: 16),

            // Buttons to pick image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Upload Button
            if (_isUploading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _uploadPost,
                child: const Text("Upload Post"),
              ),
          ],
        ),
      ),
    );
  }
}
