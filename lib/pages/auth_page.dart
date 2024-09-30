import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
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
        body: Center(
            child: Column(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: const Image(
                  image: AssetImage('assets/images/logo.jpg'),
                  width: 120,
                )),
            const SizedBox(
              height: 50,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
              child: SupaEmailAuth(
                redirectTo: 'io.supabase.natureconnect://login-callback/',
                onSignInComplete: (response) {
                  if (!mounted) return;
                  context.go('/home');
                },
                onSignUpComplete: (response) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 5),
                    content: Text("Please check your email",style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ));
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
                ],
              ),
            ),
          ],
        )));
  }
}
