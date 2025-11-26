import 'package:shring_tech/core/usecases/usecase.dart';
import 'package:shring_tech/features/jobs/domain/repositories/job_repository.dart';

class ClearCompletedJobs implements UseCase<void, NoParams> {
  final JobRepository repository;

  ClearCompletedJobs(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.clearCompletedJobs();
  }
}
