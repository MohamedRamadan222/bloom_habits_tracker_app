import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'package:bloom_habit_tracker/core/data/settings_datasource.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('settings_test');
    Hive.init(tempDir.path);
    await Hive.openBox('settings_datasource_test');
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  setUp(() async {
    await Hive.box('settings_datasource_test').clear();
  });

  SettingsDatasource ds() =>
      SettingsDatasource(Hive.box('settings_datasource_test'));

  test('getUsername is null before first save', () {
    expect(ds().getUsername(), isNull);
  });

  test('saveUsername round-trips and overwrites', () async {
    await ds().saveUsername('Alex');
    expect(ds().getUsername(), 'Alex');
    await ds().saveUsername('Sam');
    expect(ds().getUsername(), 'Sam');
  });
}
