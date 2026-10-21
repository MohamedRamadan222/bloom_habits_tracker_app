import 'package:bloom_habit_tracker/core/domain/repositories/habits_repository.dart';

class DeleteHabit {
  final HabitsRepository repository;

  DeleteHabit(this.repository);

  Future<void> call(String id) async {
    await repository.delete(id);
  }
}
