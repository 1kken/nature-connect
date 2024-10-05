import 'package:nature_connect/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileServices {
  final supabase = Supabase.instance.client;

  //READ
  Future<Profile> fetchProfile() async {
    try {
      final response = await supabase.from('profiles').select().eq('id', supabase.auth.currentUser!.id).single();
      return Profile.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

  //READ fetch profile by id
  Future<Profile> fetchProfileById(String? id) async {
    try {
      if (id == null || id.isEmpty) {
        throw 'Invalid id';
      }
      final response = await supabase.from('profiles').select().eq('id', id).single();
      return Profile.fromMap(response);
    } catch (e) {
      rethrow;
    }
  }

}