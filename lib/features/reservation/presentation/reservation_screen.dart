import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/user_prefs.dart';
import '../../../core/theme/app_colors.dart';

class ReservationScreen extends ConsumerStatefulWidget {
  const ReservationScreen({super.key});

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 13, minute: 0);
  int _guests = 2;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(userPrefsProvider);
      _nameCtrl.text = prefs.name;
      _phoneCtrl.text = prefs.phone;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _sendReservation() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Укажите имя и телефон'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final dateStr = DateFormat('dd.MM.yyyy').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    final message =
        '🍽 Бронирование стола — ПЛОВ НОМЕР 1\n\n'
        '👤 Имя: $name\n'
        '📞 Телефон: +7$phone\n'
        '📅 Дата: $dateStr\n'
        '⏰ Время: $timeStr\n'
        '👥 Гостей: $_guests'
        '${_commentCtrl.text.trim().isNotEmpty ? '\n💬 ${_commentCtrl.text.trim()}' : ''}';

    try {
      final user = Supabase.instance.client.auth.currentUser;
      await Supabase.instance.client.from('reservations').insert({
        'user_id': user?.id,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'time': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        'guests_count': _guests,
        'comment': _commentCtrl.text.trim(),
        'phone': '+7$phone',
        'name': name,
      });
      // Сохраняем данные локально после успешной брони
      await ref.read(userPrefsProvider.notifier).save(name, phone);
    } catch (_) {
      // Даже если в базу не записалось, сохраняем локально для удобства
      await ref.read(userPrefsProvider.notifier).save(name, phone);
    }

    final uri = Uri.parse(
      '${AppConfig.whatsappUrl}?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Запрос на бронирование отправлен!'),
          backgroundColor: AppColors.halal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM, EEEE', 'ru').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Бронирование стола')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Выберите дату и время',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _selectBtn(
                    icon: Icons.calendar_today_outlined,
                    label: dateStr,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                _selectBtn(
                  icon: Icons.access_time,
                  label: timeStr,
                  onTap: _pickTime,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Количество гостей',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppColors.primary, size: 32),
                  onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                ),
                const SizedBox(width: 16),
                Text(
                  '$_guests',
                  style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.primary, size: 32),
                  onPressed: _guests < 20 ? () => setState(() => _guests++) : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Контактные данные',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: 'Ваше имя',
                prefixIcon: _fieldPrefixIcon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: AppColors.cream),
              decoration: InputDecoration(
                hintText: '777 000 00 00',
                prefixText: '+7 ',
                prefixStyle: const TextStyle(color: AppColors.cream),
                prefixIcon: _fieldPrefixIcon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentCtrl,
              style: const TextStyle(color: AppColors.cream),
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Пожелания (отдельный зал, детское место...)',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendReservation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_loading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: AppColors.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      const Icon(Icons.send, size: 18),
                    const SizedBox(width: 8),
                    const Text('Отправить бронь в WhatsApp'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Подтверждение придёт по телефону',
                style: TextStyle(color: AppColors.greyLight, fontSize: 12),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _fieldPrefixIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 12),
      child: Icon(icon, color: AppColors.primary, size: 22),
    );
  }

  Widget _selectBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.cream, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
