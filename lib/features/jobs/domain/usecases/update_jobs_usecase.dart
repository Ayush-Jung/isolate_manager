import 'package:equatable/equatable.dart';
import 'package:shring_tech/core/usecases/usecase.dart';
import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';
import 'package:shring_tech/features/jobs/domain/repositories/job_repository.dart';

class UpdateJob implements UseCase<void, UpdateJobParams> {
  final JobRepository repository;

  UpdateJob(this.repository);

  @override
  Future<void> call(UpdateJobParams params) async {
    return await repository.updateJob(params.job);
  }
}

class UpdateJobParams extends Equatable {
  final JobEntity job;

  const UpdateJobParams({required this.job});

  @override
  List<Object> get props => [job];
}
