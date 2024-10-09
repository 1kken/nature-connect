import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class MediaService {
  static final _supabase = Supabase.instance.client;

//UPLOADE IMAGE TO post_media storage
  static Future<String> uploadMedia(
      String path, String postId, String mimeType,String storagePath) async {
    //generate unique id for the media
    final uuid = const Uuid().v4();

    //generate the storage path abc-def/111-222-333
    final storagePathName = '$postId/$uuid';

    //from path get xFile then convert to uint8list
    final file = File(path);
    final data = await file.readAsBytes();

    //upload the file to the storage
    await _supabase.storage.from(storagePath).uploadBinary(
        storagePathName, data,
        fileOptions: FileOptions(cacheControl: '3600', contentType: mimeType));

    //get the public url after uploading
    final url = _supabase.storage
        .from(storagePath)
        .getPublicUrl(storagePathName);

    return url;
  }
}
