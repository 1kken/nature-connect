import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  Uint8List? imageData;

  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not logged in')),
        );
        return;
      }

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: _oldPasswordController.text.trim(),
      );

      if (!mounted) return;
      if (response.session != null) {
        // Old password is correct; proceed with changing the password
        await _supabase.auth.updateUser(
          UserAttributes(password: _newPasswordController.text.trim()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Old password is incorrect')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<String?> uploadImage() async {

  // Check if imageData is not null
  if (imageData == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No image selected. Please choose an image to upload.'),
        duration: Duration(seconds: 3),
      ),
    );
    return null;
  }

  // Check if user is authenticated
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User not authenticated. Please log in to upload an avatar.'),
        duration: Duration(seconds: 3),
      ),
    );
    return null;
  }

  final imagePath = "$userId/avatar"; 

  setState(() {
    _isLoading = true;
  });

  try {

    // Upload the image using uploadBinary and await the response
    // ignore: unused_local_variable
    final response = await _supabase.storage.from('avatars').uploadBinary(
          imagePath,
          imageData!,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true, // Allows overwriting existing files
          ),
        );

    // Retrieve the public URL of the uploaded image
    final imageUrlResponse = _supabase.storage.from('avatars').getPublicUrl(imagePath);

    // Provide success feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar uploaded successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    return imageUrlResponse;
  } on StorageException catch (e) {
    // Handle specific storage exceptions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Storage Error: ${e.message}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    return null;
  } catch (e) {
    // Handle any other exceptions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An unexpected error occurred: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    return null;
  } finally {
    // Ensure the loading state is reset regardless of success or failure
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  Future<void> _updateUsername() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabase.auth.currentUser;

      if (user != null) {
        await _supabase.auth.updateUser(
          UserAttributes(data: {
            'username': _usernameController.text.trim(),
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _supabase.auth.signOut();
    if (!mounted) return;
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    final fullName =
        '${metadata['firstname'] ?? ''} ${metadata['lastname'] ?? ''}'.trim();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(120),
              child: imageData != null
                  ? Image.memory(
                      imageData!,
                      width: 150, // Adjust the size as needed
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image == null) return;
                  final imageDataBytes = await image.readAsBytes();
                  setState(() {
                    imageData = imageDataBytes;
                  });
                  uploadImage();
                },
                child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Upload Avatar')),
            const SizedBox(height: 16),

            // Displaying username
            Text(
              'Username: ${metadata['username'] ?? 'Unknown'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // Displaying full name
            Text(
              'Full Name: $fullName',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // Displaying email
            Text(
              'Email: ${user?.email ?? 'Unknown'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 16),

            // Change Username Section
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Change Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateUsername,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Update Username'),
            ),
            const SizedBox(height: 32),

            // Change Password Section
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Old Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Change Password'),
            ),
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                overlayColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
