import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class OrderSentScreen extends StatelessWidget {
  const OrderSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.primary, size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                'Заказ отправлен!',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ваш заказ отправлен в WhatsApp ресторана. Ожидайте подтверждения от оператора.',
                style: TextStyle(color: AppColors.greyLight, fontSize: 15, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '+7 707 400 77 28',
                style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Вернуться в меню'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
