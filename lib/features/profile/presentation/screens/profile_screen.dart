import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/user_prefs.dart';
import '../../../../core/l10n/delivery_l10n.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../menu/data/menu_providers.dart';
import '../../../notifications/data/fcm_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(userPrefsProvider);
    final locale = ref.watch(localeProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final phone = user?.phone ?? (prefs.phone.isNotEmpty ? '+7${prefs.phone}' : null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          if (prefs.name.isNotEmpty)
            Center(
              child: Text(
                prefs.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          const SizedBox(height: 24),
          Text(
            l10n.profileLanguage,
            style: const TextStyle(color: AppColors.greyLight, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'ru', label: Text(l10n.languageRu)),
              ButtonSegment(value: 'kk', label: Text(l10n.languageKk)),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (selected) async {
              final code = selected.first;
              await ref.read(localeProvider.notifier).setLocale(Locale(code));
              if (user != null) {
                await ref
                    .read(fcmServiceProvider)
                    .registerTokenForCurrentUser(code);
              }
            },
          ),
          const SizedBox(height: 32),
          _infoTile(
            icon: Icons.phone_outlined,
            label: l10n.profilePhone,
            value: phone ?? l10n.profilePhoneMissing,
          ),
          if (prefs.lastAddress.isNotEmpty) ...[
            const SizedBox(height: 1),
            _infoTile(
              icon: Icons.location_on_outlined,
              label: l10n.profileLastAddress,
              value: prefs.lastAddress,
            ),
          ],
          const SizedBox(height: 24),
          InkWell(
            onTap: () => context.push('/orders'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.profileOrders,
                      style: const TextStyle(
                          color: AppColors.cream, fontSize: 15),
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.grey, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(signOutProvider)();
            },
            icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
            label: Text(
              l10n.profileLogout,
              style: const TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.greyLight, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.cream, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
