import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/delivery_l10n.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../notifications/data/fcm_service.dart';

final _phoneProvider = StateProvider<String>((_) => '');
final _otpSentProvider = StateProvider<bool>((_) => false);
final _loadingProvider = StateProvider<bool>((_) => false);

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final l10n = context.l10n;
    final phone = '+7${_phoneCtrl.text.replaceAll(RegExp(r'\D'), '')}';
    if (phone.length < 11) {
      _showError(l10n.errorPhoneInvalid);
      return;
    }
    ref.read(_loadingProvider.notifier).state = true;
    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: phone);
      ref.read(_phoneProvider.notifier).state = phone;
      ref.read(_otpSentProvider.notifier).state = true;
    } catch (e) {
      _showError(l10n.errorOtpSend('$e'));
    } finally {
      ref.read(_loadingProvider.notifier).state = false;
    }
  }

  Future<void> _verifyOtp() async {
    final l10n = context.l10n;
    final phone = ref.read(_phoneProvider);
    final token = _otpCtrl.text.trim();
    if (token.length != 6) {
      _showError(l10n.errorOtpInvalid);
      return;
    }
    ref.read(_loadingProvider.notifier).state = true;
    try {
      await Supabase.instance.client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      final locale = ref.read(localeProvider).languageCode;
      await ref.read(fcmServiceProvider).registerTokenForCurrentUser(locale);
      if (mounted) context.pop();
    } catch (e) {
      _showError(l10n.errorOtpWrong);
    } finally {
      ref.read(_loadingProvider.notifier).state = false;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final otpSent = ref.watch(_otpSentProvider);
    final loading = ref.watch(_loadingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otpSent ? l10n.authOtpTitle : l10n.authPhoneTitle,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              otpSent
                  ? l10n.authOtpSubtitle(ref.watch(_phoneProvider))
                  : l10n.authPhoneSubtitle,
              style: const TextStyle(color: AppColors.greyLight),
            ),
            const SizedBox(height: 32),
            if (!otpSent) ...[
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                style: const TextStyle(color: AppColors.cream, fontSize: 18),
                decoration: InputDecoration(
                  prefixText: '+7 ',
                  prefixStyle: const TextStyle(color: AppColors.cream, fontSize: 18),
                  hintText: l10n.checkoutPhoneHint,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: loading ? null : _sendOtp,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(l10n.authGetCode),
              ),
            ] else ...[
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 6,
                style: const TextStyle(
                    color: AppColors.cream, fontSize: 28, letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    counterText: '', hintText: l10n.authOtpHint),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: loading ? null : _verifyOtp,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(l10n.authConfirm),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => ref.read(_otpSentProvider.notifier).state = false,
                  child: Text(l10n.authChangePhone),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
