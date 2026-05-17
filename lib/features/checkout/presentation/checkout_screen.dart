import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/delivery_rules.dart';
import '../../../core/config/user_prefs.dart';
import '../../../core/l10n/delivery_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart/data/cart_provider.dart';

enum DeliveryType { delivery, pickup }

final _deliveryTypeProvider = StateProvider.autoDispose((_) => DeliveryType.delivery);

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(userPrefsProvider);
      _nameCtrl.text = prefs.name;
      if (prefs.lastAddress.isNotEmpty) _addressCtrl.text = prefs.lastAddress;
      if (prefs.phone.isNotEmpty) {
        _phoneCtrl.text = prefs.phone;
      } else {
        final user = Supabase.instance.client.auth.currentUser;
        if (user?.phone != null) {
          _phoneCtrl.text = user!.phone!.replaceFirst('+7', '');
        }
      }
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _commentCtrl.dispose();
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final delivery = ref.read(_deliveryTypeProvider);
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    final l10n = context.l10n;
    if (phone.isEmpty) {
      _showError(l10n.errorPhoneRequired);
      return;
    }
    if (delivery == DeliveryType.delivery && address.isEmpty) {
      _showError(l10n.errorAddressRequired);
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      context.push('/auth');
      return;
    }

    setState(() => _loading = true);

    final cart = ref.read(cartProvider);
    final subtotal = ref.read(cartTotalProvider);
    final isDelivery = delivery == DeliveryType.delivery;
    final fee = deliveryFeeForSubtotal(subtotal, isDelivery: isDelivery);
    final grandTotal = orderGrandTotal(subtotal, fee);
    final now = DateFormat('HH:mm').format(DateTime.now());

    final lines = cart.map((ci) {
      final modsStr = ci.modifiers.isEmpty
          ? ''
          : ' (${ci.modifiers.map((m) => m.name).join(', ')})';
      final price = ci.total;
      return '- ${ci.item.name}$modsStr x${ci.quantity} — ${formatTenge(price)} тг';
    }).join('\n');

    final deliveryLabel = isDelivery ? l10n.checkoutDelivery : l10n.checkoutPickup;
    final deliveryFeeLine = isDelivery
        ? '\n🚚 Доставка: ${context.l10n.deliveryFeeShortLabel(subtotal, isDelivery: true)}'
        : '';
    final addressLine = isDelivery && address.isNotEmpty
        ? '\n📍 Адрес: $address'
        : '';
    final commentLine = _commentCtrl.text.trim().isNotEmpty
        ? '\n💬 Комментарий: ${_commentCtrl.text.trim()}'
        : '';

    final message =
        '''🍽 Новый заказ — PlovХана

📋 Состав:
$lines

🍽 Сумма блюд: ${formatTenge(subtotal)} тг$deliveryFeeLine
💰 Итого: ${formatTenge(grandTotal)} тг
🚗 $deliveryLabel
💵 Оплата: Наличные / Kaspi перевод$addressLine
👤 Имя: ${name.isEmpty ? l10n.profilePhoneMissing : name}
📞 Телефон: +7$phone$commentLine

⏰ $now''';

    // Сохраняем данные локально в любом случае
    await ref.read(userPrefsProvider.notifier).save(name, phone);
    if (isDelivery) await ref.read(userPrefsProvider.notifier).saveAddress(address);

    // Пробуем записать в БД (для истории заказов), ошибка не блокирует заказ
    try {
      await Supabase.instance.client.from('orders').insert({
        'user_id': user.id,
        'status': 'pending',
        'items_json': cart
            .map((ci) => {
                  'item_id': ci.item.id,
                  'name': ci.item.name,
                  'price': ci.item.price,
                  'quantity': ci.quantity,
                })
            .toList(),
        'total': grandTotal,
        'delivery_type': delivery.name,
        'address': address,
        'phone': '+7$phone',
        'comment': _commentCtrl.text.trim(),
      });
    } catch (_) {
      // БД недоступна — продолжаем, WhatsApp является основным каналом заказа
    }

    final uri = Uri.parse(
      '${AppConfig.whatsappUrl}?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      _showError('Не удалось открыть WhatsApp');
      setState(() => _loading = false);
      return;
    }

    ref.read(cartProvider.notifier).clear();
    if (mounted) {
      setState(() => _loading = false);
      context.go('/order-sent');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final delivery = ref.watch(_deliveryTypeProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final isDelivery = delivery == DeliveryType.delivery;
    final fee = deliveryFeeForSubtotal(subtotal, isDelivery: isDelivery);
    final grandTotal = orderGrandTotal(subtotal, fee);
    final l10n = context.l10n;
    final shopOpen = isShopOpen();
    final minErr = l10n.minOrderError(subtotal, isDelivery: isDelivery);
    final canOrder = shopOpen && minErr == null && !_loading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(l10n.checkoutDeliveryType),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _typeBtn(
                    label: l10n.checkoutDelivery,
                    icon: Icons.delivery_dining,
                    selected: delivery == DeliveryType.delivery,
                    onTap: () =>
                        ref.read(_deliveryTypeProvider.notifier).state =
                            DeliveryType.delivery,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _typeBtn(
                    label: l10n.checkoutPickup,
                    icon: Icons.storefront,
                    selected: delivery == DeliveryType.pickup,
                    onTap: () =>
                        ref.read(_deliveryTypeProvider.notifier).state =
                            DeliveryType.pickup,
                  ),
                ),
              ],
            ),
            if (delivery == DeliveryType.delivery) ...[
              const SizedBox(height: 20),
              _sectionTitle(l10n.checkoutAddress),
              const SizedBox(height: 8),
              TextField(
                controller: _addressCtrl,
                style: const TextStyle(color: AppColors.cream),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: l10n.checkoutAddressHint,
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _sectionTitle(l10n.checkoutContacts),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: l10n.checkoutNameHint,
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: l10n.checkoutPhoneHint,
                prefixText: '+7 ',
                prefixStyle: const TextStyle(color: AppColors.cream),
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle(l10n.checkoutComment),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              style: const TextStyle(color: AppColors.cream),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.checkoutCommentHint,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _totalRow(l10n.checkoutSubtotal, l10n.currencyTenge(formatTenge(subtotal))),
                  const SizedBox(height: 8),
                  _totalRow(
                    l10n.checkoutDeliveryFee,
                    l10n.deliveryFeeShortLabel(subtotal, isDelivery: isDelivery),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.divider, height: 1),
                  ),
                  _totalRow(
                    l10n.checkoutTotal,
                    l10n.currencyTenge(formatTenge(grandTotal)),
                    valueStyle: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!shopOpen) ...[
              _infoBanner(
                icon: Icons.access_time_rounded,
                text: l10n.shopClosedMessage(),
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
            ],
            if (minErr != null) ...[
              _infoBanner(
                icon: Icons.shopping_bag_outlined,
                text: minErr,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton.icon(
              onPressed: canOrder ? _placeOrder : null,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, size: 18),
              label: Text(l10n.checkoutSubmit),
            ),
            if (canOrder) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  l10n.checkoutSubmitHint,
                  style: const TextStyle(color: AppColors.greyLight, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.greyLight, fontSize: 14),
        ),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(
                color: AppColors.cream,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _infoBanner({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.cream,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _typeBtn({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.greyLight,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
