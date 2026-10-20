import '../repositories/habits_repository.dart';

class GetStreak {
  final HabitsRepository repository;
  GetStreak(this.repository);

  int call() {
    return repository.streak();
  }
}