import 'package:shring_tech/core/usecases/usecase.dart';
import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';
import 'package:shring_tech/features/jobs/domain/repositories/job_repository.dart';

class GetJobs implements UseCase<List<JobEntity>, NoParams> {
  final JobRepository repository;

  GetJobs(this.repository);

  @override
  Future<List<JobEntity>> call(NoParams params) async {
    return await repository.getJobs();
  }
}
