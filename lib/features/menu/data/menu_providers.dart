import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../notifications/data/fcm_service.dart';
import '../../../core/config/user_prefs.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/menu_item.dart';
import '../../../shared/models/modifier_group.dart';
import '../../../shared/models/promotion.dart';

final supabaseProvider = Provider<SupabaseClient>((_) => Supabase.instance.client);
final signOutProvider = Provider((ref) => () async {
      await ref.read(fcmServiceProvider).unregisterCurrentUser();
      await Supabase.instance.client.auth.signOut();
    });

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  const cacheKey = 'cache_categories';
  final prefs = ref.read(sharedPreferencesProvider);
  final client = ref.read(supabaseProvider);

  try {
    final catsRaw = await client
        .from('categories')
        .select()
        .order('sort_order')
        .order('name');
    final itemsRaw = await client
        .from('menu_items')
        .select('category_id')
        .eq('is_available', true);
    final activeCatIds = {
      for (final row in itemsRaw as List) row['category_id'] as String
    };
    final result = (catsRaw as List)
        .map((e) => Category.fromJson(e))
        .where((c) => activeCatIds.contains(c.id))
        .toList();
    prefs.setString(cacheKey, jsonEncode(result.map((c) => c.toJson()).toList()));
    return result;
  } catch (_) {
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      return (jsonDecode(cached) as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    rethrow;
  }
});

final menuItemsByCategoryProvider =
    FutureProvider.family<List<MenuItem>, String>((ref, categoryId) async {
  final client = ref.read(supabaseProvider);
  final data = await client
      .from('menu_items')
      .select()
      .eq('category_id', categoryId)
      .eq('is_available', true)
      .order('sort_order')
      .order('name');
  return (data as List).map((e) => MenuItem.fromJson(e)).toList();
});

final popularItemsProvider = FutureProvider<List<MenuItem>>((ref) async {
  final client = ref.read(supabaseProvider);
  final popularData = await client
      .from('menu_items')
      .select()
      .eq('is_available', true)
      .eq('is_popular', true)
      .order('sort_order')
      .limit(10);
  final popular = (popularData as List).map((e) => MenuItem.fromJson(e)).toList();
  if (popular.isNotEmpty) return popular;
  final fallbackData = await client
      .from('menu_items')
      .select()
      .eq('is_available', true)
      .order('sort_order')
      .limit(10);
  return (fallbackData as List).map((e) => MenuItem.fromJson(e)).toList();
});

final promotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  final client = ref.read(supabaseProvider);
  final data = await client
      .from('promotions')
      .select()
      .eq('active', true)
      .order('created_at', ascending: false);
  return (data as List).map((e) => Promotion.fromJson(e)).toList();
});

final newItemsProvider = FutureProvider<List<MenuItem>>((ref) async {
  final client = ref.read(supabaseProvider);
  final data = await client
      .from('menu_items')
      .select()
      .eq('is_available', true)
      .order('created_at', ascending: false)
      .limit(10);
  return (data as List).map((e) => MenuItem.fromJson(e)).toList();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchNotifier extends AutoDisposeAsyncNotifier<List<MenuItem>> {
  Timer? _timer;
  int _requestId = 0;

  @override
  Future<List<MenuItem>> build() async => [];

  void search(String query) {
    _timer?.cancel();
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    _timer = Timer(const Duration(milliseconds: 300), () async {
      final id = ++_requestId;
      state = const AsyncLoading();
      final result = await AsyncValue.guard(() async {
        final client = ref.read(supabaseProvider);
        final data = await client
            .from('menu_items')
            .select()
            .ilike('name', '%${query.trim()}%')
            .eq('is_available', true)
            .limit(20);
        return (data as List).map((e) => MenuItem.fromJson(e)).toList();
      });
      if (id == _requestId) state = result;
    });
  }
}

final searchProvider =
    AsyncNotifierProvider.autoDispose<SearchNotifier, List<MenuItem>>(
  SearchNotifier.new,
);

final menuItemByIdProvider =
    FutureProvider.family<MenuItem?, String>((ref, id) async {
  final data = await ref
      .read(supabaseProvider)
      .from('menu_items')
      .select()
      .eq('id', id)
      .single();
  return MenuItem.fromJson(data);
});

final modifierGroupsProvider =
    FutureProvider.family<List<ModifierGroup>, String>((ref, menuItemId) async {
  final data = await ref
      .read(supabaseProvider)
      .from('modifier_groups')
      .select('*, modifiers(*)')
      .eq('menu_item_id', menuItemId)
      .order('sort_order');
  return (data as List).map((e) => ModifierGroup.fromJson(e)).toList();
});
