import '../../data/settings_datasource.dart';

class GetUsername {
  final SettingsDatasource datasource;

  GetUsername(this.datasource);

  String? call() {
    return datasource.getUsername();
  }
}
