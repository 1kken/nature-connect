import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
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
  String? _imageUrl;
  Uint8List? imageData;

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    getimgUrl();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> getimgUrl() async {
    final userId = _supabase.auth.currentUser?.id;
    final imgUrl = await _supabase
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId!)
        .single();
    setState(() {
      _imageUrl = imgUrl['avatar_url'];
      print(_imageUrl);
    });
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

  Future<void> uploadImage(String mimetype) async {
    // Check if imageData is not null
    if (imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image selected. Please choose an image to upload.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Check if user is authenticated
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'User not authenticated. Please log in to upload an avatar.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
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
            fileOptions: FileOptions(
                cacheControl: '3600',
                upsert: true, // Allows overwriting existing files
                contentType: mimetype),
          );

      // Retrieve the public URL of the uploaded image
      final imageUrlResponse =
          _supabase.storage.from('avatars').getPublicUrl(imagePath);
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("id is null"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      await _supabase
          .from('profiles')
          .update({'avatar_url': imageUrlResponse}).eq('id', userId);

      // Provide success feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar uploaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      return;
    } on StorageException catch (e) {
      // Handle specific storage exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Storage Error: ${e.message}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    } catch (e) {
      // Handle any other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
      );
      return;
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
            CircleAvatar(
              radius:
                  75, // Adjust the radius as needed (this gives a 150x150 size)
              backgroundColor:
                  Colors.grey[300], // Background color for placeholder
              child: ClipOval(
                child: _imageUrl != null && imageData == null
                    ? Image.network(
                        _imageUrl!, // Show image from URL if available
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : imageData != null
                        ? Image.memory(
                            imageData!, // Show image from memory if imageData is available
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons
                                .person, // Show placeholder icon if no image is available
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
                  final mime = lookupMimeType(image.path);
                  setState(() {
                    imageData = imageDataBytes;
                  });
                  uploadImage(mime!);
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
