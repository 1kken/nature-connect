import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
        return Scaffold(
          // body: SupaResetPassword(onSuccess: (response){})
          body: FloatingActionButton(
            child: const Text("Sign out"),
            onPressed: (){
            Supabase.instance.client.auth.signOut();
            context.go('/');
          }),
        );
  }
}