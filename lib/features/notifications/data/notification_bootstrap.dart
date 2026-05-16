import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/l10n/locale_provider.dart';
import 'fcm_service.dart';

class NotificationBootstrap extends ConsumerStatefulWidget {
  const NotificationBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationBootstrap> createState() =>
      _NotificationBootstrapState();
}

class _NotificationBootstrapState extends ConsumerState<NotificationBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPushToken());
    ref.read(fcmServiceProvider).initialize();
  }

  Future<void> _syncPushToken() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final locale = ref.read(localeProvider).languageCode;
    await ref.read(fcmServiceProvider).registerTokenForCurrentUser(locale);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(localeProvider, (_, next) async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      await ref.read(fcmServiceProvider).registerTokenForCurrentUser(next.languageCode);
    });

    return widget.child;
  }
}
