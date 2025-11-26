import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';

abstract class JobRepository {
  Future<List<JobEntity>> getJobs();
  Future<void> reOrderJobs(List<JobEntity> jobs);
  Future<void> clearCompletedJobs();
  Future<void> resetAllJobs();
  Future<void> updateJob(JobEntity job);
  Future<void> saveJobs(List<JobEntity> jobs);
}
