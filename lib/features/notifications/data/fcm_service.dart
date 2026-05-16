import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/router/app_router.dart';
import 'push_token_repository.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    ref.read(pushTokenRepositoryProvider),
    ref,
  );
});

class FcmService {
  FcmService(this._repository, this._ref);

  final PushTokenRepository _repository;
  final Ref _ref;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _openOrdersFromNotification();
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _openOrdersFromNotification();
      }

      messaging.onTokenRefresh.listen((token) async {
        final locale = _ref.read(localeProvider).languageCode;
        await _repository.upsertToken(fcmToken: token, locale: locale);
      });
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('FCM init error: $e\n$st');
      }
    }
  }

  Future<void> registerTokenForCurrentUser(String locale) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _repository.upsertToken(fcmToken: token, locale: locale);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('FCM token register error: $e\n$st');
      }
    }
  }

  Future<void> unregisterCurrentUser() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _repository.deleteToken(token);
      } else {
        await _repository.deleteCurrentUserTokens();
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('FCM unregister error: $e\n$st');
      }
    }
  }

  void _openOrdersFromNotification() {
    router.go('/orders');
  }
}
