import 'package:nature_connect/model/marketplace_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketplaceMediaService {
  final _id = Supabase.instance.client.auth.currentUser?.id;
  final _supabase = Supabase.instance.client;

  //CREATE marketplace_media
  Future<String> insertMarketplaceMedia(String itemId, int index, String storageUrl,String mimeType) async {
    final userId = _id;
    if (userId == null) {
      return '';
    }

    final data = {
      'user_id': userId,
      'item_id': itemId,
      'index': index,
      'storage_url': storageUrl,
      'mime_type': mimeType,
    };

    //try catch and return the id of the marketplace_media
    try {
      final response = await _supabase.from('marketplace_media').insert(data);
      return response.data.first['id'];
    } catch (e) {
      rethrow;
    }
  }

  //READ
  Future<List<MarketplaceMedia>> getMarketplaceMedia(String itemId) async {
    List<MarketplaceMedia> marketplaceMedia = [];
    try {
      final response = await _supabase.from('marketplace_media').select().eq('item_id', itemId);
      for (var record in response) {
        marketplaceMedia.add(MarketplaceMedia.fromMap(record));
      }
      return marketplaceMedia;
    } catch (e) {
      rethrow;
    }
  }

  //STREAM
  Stream<List<MarketplaceMedia>> getMarketplaceMediaStream(String itemId) {
    return _supabase
        .from('marketplace_media')
        .stream(primaryKey: ['id'])
        .eq('item_id', itemId)
        .map((data) => data.map((e) => MarketplaceMedia.fromMap(e)).toList());
  }

  
}