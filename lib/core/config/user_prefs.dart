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
  ));

  Future<void> updateName(String name) async {
    await _prefs.setString('user_name', name);
    state = state.copyWith(name: name);
  }

  Future<void> updatePhone(String phone) async {
    await _prefs.setString('user_phone', phone);
    state = state.copyWith(phone: phone);
  }

  Future<void> save(String name, String phone) async {
    await _prefs.setString('user_name', name);
    await _prefs.setString('user_phone', phone);
    state = UserPrefsState(name: name, phone: phone);
  }
}

class UserPrefsState {
  final String name;
  final String phone;

  UserPrefsState({required this.name, required this.phone});

  UserPrefsState copyWith({String? name, String? phone}) {
    return UserPrefsState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}

final userPrefsProvider = StateNotifierProvider<UserPrefsNotifier, UserPrefsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserPrefsNotifier(prefs);
});
