import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/delivery_rules.dart';
import '../../../core/config/user_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart/data/cart_provider.dart';

enum DeliveryType { delivery, pickup }

final _deliveryTypeProvider = StateProvider((_) => DeliveryType.delivery);

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

    if (phone.isEmpty) {
      _showError('Укажите номер телефона');
      return;
    }
    if (delivery == DeliveryType.delivery && address.isEmpty) {
      _showError('Укажите адрес доставки');
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
      final price = ci.item.price * ci.quantity;
      return '- ${ci.item.name} x${ci.quantity} — ${formatTenge(price)} тг';
    }).join('\n');

    final deliveryLabel = isDelivery ? 'Доставка' : 'Самовывоз';
    final deliveryFeeLine = isDelivery
        ? '\n🚚 Доставка: ${deliveryFeeShortLabel(subtotal, isDelivery: true)}'
        : '';
    final addressLine = isDelivery && address.isNotEmpty
        ? '\n📍 Адрес: $address'
        : '';
    final commentLine = _commentCtrl.text.trim().isNotEmpty
        ? '\n💬 Комментарий: ${_commentCtrl.text.trim()}'
        : '';

    final message = '''🍽 Новый заказ — ПЛОВ НОМЕР 1

📋 Состав:
$lines

🍽 Сумма блюд: ${formatTenge(subtotal)} тг$deliveryFeeLine
💰 Итого: ${formatTenge(grandTotal)} тг
🚗 $deliveryLabel
💵 Оплата: Наличные / Kaspi перевод$addressLine
👤 Имя: ${name.isEmpty ? 'не указано' : name}
📞 Телефон: +7$phone$commentLine

⏰ $now''';

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
      // Сохраняем данные локально после успешного (или попытки) заказа
      await ref.read(userPrefsProvider.notifier).save(name, phone);
    } catch (_) {
      // Заказ всё равно уходит в WhatsApp
      await ref.read(userPrefsProvider.notifier).save(name, phone);
    }

    final uri = Uri.parse(
      '${AppConfig.whatsappUrl}?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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

    return Scaffold(
      appBar: AppBar(title: const Text('Оформление заказа')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Тип получения'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _typeBtn(
                    label: 'Доставка',
                    icon: Icons.delivery_dining,
                    selected: delivery == DeliveryType.delivery,
                    onTap: () => ref.read(_deliveryTypeProvider.notifier).state =
                        DeliveryType.delivery,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _typeBtn(
                    label: 'Самовывоз',
                    icon: Icons.storefront,
                    selected: delivery == DeliveryType.pickup,
                    onTap: () => ref.read(_deliveryTypeProvider.notifier).state =
                        DeliveryType.pickup,
                  ),
                ),
              ],
            ),
            if (delivery == DeliveryType.delivery) ...[
              const SizedBox(height: 20),
              _sectionTitle('Адрес доставки'),
              const SizedBox(height: 8),
              TextField(
                controller: _addressCtrl,
                style: const TextStyle(color: AppColors.cream),
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Улица, дом, квартира',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _sectionTitle('Контактные данные'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.cream),
              decoration: const InputDecoration(
                hintText: 'Ваше имя',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.cream),
              decoration: const InputDecoration(
                hintText: '777 000 00 00',
                prefixText: '+7 ',
                prefixStyle: TextStyle(color: AppColors.cream),
                prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Комментарий'),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              style: const TextStyle(color: AppColors.cream),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Пожелания, аллергии, уточнения...',
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
                  _totalRow('Сумма блюд', '${formatTenge(subtotal)} тг'),
                  const SizedBox(height: 8),
                  _totalRow(
                    'Доставка',
                    deliveryFeeShortLabel(subtotal, isDelivery: isDelivery),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.divider, height: 1),
                  ),
                  _totalRow(
                    'Итого',
                    '${formatTenge(grandTotal)} тг',
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
            ElevatedButton.icon(
              onPressed: _loading ? null : _placeOrder,
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
              label: const Text('Отправить заказ в WhatsApp'),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Откроется WhatsApp с вашим заказом',
                style: TextStyle(color: AppColors.greyLight, fontSize: 12),
              ),
            ),
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
        Text(label, style: const TextStyle(color: AppColors.greyLight, fontSize: 14)),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(color: AppColors.cream, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(
      color: AppColors.cream, fontSize: 16, fontWeight: FontWeight.w600));
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
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
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
