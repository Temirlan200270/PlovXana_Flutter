import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/menu_item.dart';
import '../../../shared/models/promotion.dart';

final supabaseProvider = Provider<SupabaseClient>((_) => Supabase.instance.client);
final signOutProvider = Provider((_) => () => Supabase.instance.client.auth.signOut());

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final client = ref.read(supabaseProvider);
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
  return (catsRaw as List)
      .map((e) => Category.fromJson(e))
      .where((c) => activeCatIds.contains(c.id))
      .toList();
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

final searchResultsProvider = FutureProvider<List<MenuItem>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final client = ref.read(supabaseProvider);
  final data = await client
      .from('menu_items')
      .select()
      .ilike('name', '%$query%')
      .eq('is_available', true)
      .limit(20);
  
  return (data as List).map((e) => MenuItem.fromJson(e)).toList();
});
