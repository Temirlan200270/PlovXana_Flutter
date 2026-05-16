import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class UserPrefsNotifier extends StateNotifier<UserPrefsState> {
  final SharedPreferences _prefs;

  UserPrefsNotifier(this._prefs) : super(UserPrefsState(
    name: _prefs.getString('user_name') ?? '',
    phone: _prefs.getString('user_phone') ?? '',
    lastAddress: _prefs.getString('user_last_address') ?? '',
  ));

  Future<void> save(String name, String phone) async {
    await _prefs.setString('user_name', name);
    await _prefs.setString('user_phone', phone);
    state = state.copyWith(name: name, phone: phone);
  }

  Future<void> saveAddress(String address) async {
    if (address.isEmpty) return;
    await _prefs.setString('user_last_address', address);
    state = state.copyWith(lastAddress: address);
  }
}

class UserPrefsState {
  final String name;
  final String phone;
  final String lastAddress;

  UserPrefsState({
    required this.name,
    required this.phone,
    this.lastAddress = '',
  });

  UserPrefsState copyWith({String? name, String? phone, String? lastAddress}) {
    return UserPrefsState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      lastAddress: lastAddress ?? this.lastAddress,
    );
  }
}

final userPrefsProvider = StateNotifierProvider<UserPrefsNotifier, UserPrefsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserPrefsNotifier(prefs);
});
