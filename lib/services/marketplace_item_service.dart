import 'package:mime/mime.dart';
import 'package:nature_connect/model/marketplace_item.dart';
import 'package:nature_connect/services/marketplace_media_service.dart';
import 'package:nature_connect/services/media_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketplaceItemService {
  final _user = Supabase.instance.client.auth.currentUser;
  final _supabase = Supabase.instance.client;

  //CREATE
  Future<String> insertMarketplaceItem(String userId, String title,
      String caption, double price, int stock) async {
    final userId = _user?.id;
    if (userId == null) {
      return '';
    }

    final data = {
      'user_id': userId,
      'title': title,
      'caption': caption,
      'stock': stock,
      'price': price,
    };

    //try catch and return the id of the marketplace_itm
    try {
      final response = await _supabase.from('marketplace_item').insert(data).select().single();
      return response['id'].toString();
    } catch (e) {
      rethrow;
    }

  }

  //CREATE POST WITH MEDIA
  Future<void> insertMarketplaceItemWithMedia(String userId, String title,
    String caption, double price, int stock, List<String> mediaUrls) async {
    final userId = _user?.id;
    if (userId == null) {
      return;
    }

    //create marketplace item
    final itemId = await insertMarketplaceItem(userId, title, caption, price, stock);

    //loop through the media urls and look for the mime type
    for (var mediaUrl in mediaUrls) {
      final mimeType = lookupMimeType(mediaUrl);
      final index = mediaUrls.indexOf(mediaUrl);

      if (mimeType == null) {
        continue;
      }

      //upload media
      final mediaStorageUrl = await MediaService.uploadMedia(mediaUrl, itemId, mimeType, 'marketplace_media');
       
      //insert marketplace_media
      await MarketplaceMediaService().insertMarketplaceMedia(itemId,index,mediaStorageUrl,mimeType);
    }
  }

  //READ
  Future<List<MarketplaceItem>> getMarketplaceItems() async {
    List<MarketplaceItem> marketplaceItems = [];
    try {
      final response = await _supabase.from('marketplace_item').select();
      for (var record in response) {
        marketplaceItems.add(MarketplaceItem.fromMap(record));
      }
      return marketplaceItems;
    } catch (e) {
      rethrow;
    }
  }

  //READ SINGLE BY ID
  Future<MarketplaceItem?> getMarketplaceItemById(String id) async {
    try {
      final response =
          await _supabase.from('marketplace_item').select().eq('id', id);
      if (response.isEmpty) {
        return null;
      }
      return MarketplaceItem.fromMap(response.first);
    } catch (e) {
      rethrow;
    }
  }
}
