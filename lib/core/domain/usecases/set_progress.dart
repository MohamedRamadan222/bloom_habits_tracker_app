import '../repositories/habits_repository.dart';

class SetProgress {
  final HabitsRepository repository;

  SetProgress(this.repository);

  Future<void> call(String id, DateTime date, int amount) async {
    await repository.setProgress(id, date, amount);
  }
}