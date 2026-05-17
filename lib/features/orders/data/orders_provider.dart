import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/menu/data/menu_providers.dart';
import '../../../shared/models/order.dart';

final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];
  final data = await ref
      .read(supabaseProvider)
      .from('orders')
      .select()
      .eq('user_id', user.id)
      .order('created_at', ascending: false)
      .limit(50);
  return (data as List).map((e) => Order.fromJson(e)).toList();
});
