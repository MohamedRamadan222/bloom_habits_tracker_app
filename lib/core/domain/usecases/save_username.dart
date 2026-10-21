import 'package:bloom_habit_tracker/core/data/settings_datasource.dart';

class SaveUsername {
  final SettingsDatasource datasource;

  SaveUsername(this.datasource);

  Future<void> call(String name) async {
    await datasource.saveUsername(name);
  }
}
