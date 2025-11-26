import 'package:equatable/equatable.dart';
import 'package:shring_tech/core/usecases/usecase.dart';
import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';
import 'package:shring_tech/features/jobs/domain/repositories/job_repository.dart';

class ReorderJobs implements UseCase<void, ReorderJobsParams> {
  final JobRepository repository;

  ReorderJobs(this.repository);

  @override
  Future<void> call(ReorderJobsParams params) async {
    return await repository.reOrderJobs(params.jobs);
  }
}

class ReorderJobsParams extends Equatable {
  final List<JobEntity> jobs;

  const ReorderJobsParams({required this.jobs});

  @override
  List<Object> get props => [jobs];
}
