import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../controllers/user-controller.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({Key? key}) : super(key: key);

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();

  // Form fields
  String _name = '';
  String _lastname = '';
  String _biography = '';
  String _phone = '';
  File? _imageFile;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data
  Future<void> _loadUserData() async {
    final userData = await _userController.getUserData();
    if (userData != null) {
      setState(() {
        _name = userData['name'] ?? '';
        _lastname = userData['lastname'] ?? '';
        _biography = userData['biography'] ?? '';
        _phone = userData['phone'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    try {
      await _userController.saveUserData(
        name: _name.isNotEmpty ? _name : null, // Pass only if edited
        lastname: _lastname.isNotEmpty ? _lastname : null,
        biography: _biography.isNotEmpty ? _biography : null,
        phone: _phone.isNotEmpty ? _phone : null,
        imageFile: _imageFile,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name field
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value ?? '',
              ),
              const SizedBox(height: 16),

              // Lastname field
              TextFormField(
                initialValue: _lastname,
                decoration: const InputDecoration(labelText: 'Lastname'),
                onSaved: (value) => _lastname = value ?? '',
              ),
              const SizedBox(height: 16),

              // Biography field
              TextFormField(
                initialValue: _biography,
                decoration: const InputDecoration(labelText: 'Biography'),
                onSaved: (value) => _biography = value ?? '',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Phone field
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (value) => _phone = value ?? '',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Image picker
              Row(
                children: [
                  _imageFile != null
                      ? CircleAvatar(
                    radius: 40,
                    backgroundImage: FileImage(_imageFile!),
                  )
                      : const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person),
                  ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Image'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _saveUserData,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
