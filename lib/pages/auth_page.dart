import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSigningIn = true; // Add this variable to track sign-in state

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    final Session? session = Supabase.instance.client.auth.currentSession;

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (session != null) {
      // If a session exists, navigate to the home page
      context.go('/home');
    } else {
      // If no session exists, navigate to the auth page
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("NatureConnect"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),

                // Conditionally show or hide the image based on _isSigningIn state
                if (_isSigningIn)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: const Image(
                      image: AssetImage('assets/images/logo.jpg'),
                      width: 120,
                    ),
                  ),

                if (_isSigningIn) const SizedBox(height: 50),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: SupaEmailAuth(
                    redirectTo: 'io.supabase.natureconnect://login-callback/',
                    onSignInComplete: (response) {
                      if (!mounted) return;
                      context.go('/home');
                    },
                    onSignUpComplete: (response) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 10),
                        content: Text(
                          "Please check your email",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                      ));
                    },

                    // Callback that triggers when toggling between sign-in and sign-up
                    onToggleSignIn: (isSigningIn) {
                      setState(() {
                        _isSigningIn =
                            isSigningIn; // Update the state based on the toggle
                      });
                    },

                    metadataFields: [
                      MetaDataField(
                        prefixIcon: const Icon(Icons.person),
                        label: 'Username',
                        key: 'username',
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter something';
                          }
                          return null;
                        },
                      ),
                      MetaDataField(
                        prefixIcon: const Icon(Icons.person_2_outlined),
                        label: 'First Name',
                        key: 'firstname',
                      ),
                      MetaDataField(
                        prefixIcon: const Icon(Icons.person_2_outlined),
                        label: 'Last Name',
                        key: 'lastname',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
