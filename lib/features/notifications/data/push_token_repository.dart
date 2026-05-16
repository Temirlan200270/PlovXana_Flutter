import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../menu/data/menu_providers.dart';

final pushTokenRepositoryProvider = Provider<PushTokenRepository>((ref) {
  return PushTokenRepository(ref.read(supabaseProvider));
});

class PushTokenRepository {
  PushTokenRepository(this._client);

  final SupabaseClient _client;

  String get _platform {
    if (kIsWeb) return 'android';
    return Platform.isIOS ? 'ios' : 'android';
  }

  Future<void> upsertToken({
    required String fcmToken,
    required String locale,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('push_tokens').upsert(
      {
        'user_id': user.id,
        'fcm_token': fcmToken,
        'platform': _platform,
        'locale': locale == 'kk' ? 'kk' : 'ru',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,fcm_token',
    );
  }

  Future<void> deleteCurrentUserTokens() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('push_tokens').delete().eq('user_id', user.id);
  }

  Future<void> deleteToken(String fcmToken) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client
        .from('push_tokens')
        .delete()
        .eq('user_id', user.id)
        .eq('fcm_token', fcmToken);
  }
}
