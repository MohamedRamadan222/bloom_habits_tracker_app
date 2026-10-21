import 'package:hive_ce/hive.dart';

class SettingsDatasource {
  final Box _box;

  SettingsDatasource(this._box);

  Future<void> saveUsername(String name) async {
    await _box.put('username', name);
  }

  String? getUsername() {
    return _box.get('username');
  }
}
