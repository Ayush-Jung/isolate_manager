import 'package:shring_tech/features/jobs/data/datasources/job_local_datasource.dart';
import 'package:shring_tech/features/jobs/data/models/job_model.dart';
import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';
import 'package:shring_tech/features/jobs/domain/repositories/job_repository.dart';

class JobRepositoryImpl implements JobRepository {
  final JobLocalDatasource localDataSource;

  JobRepositoryImpl({required this.localDataSource});

  @override
  Future<List<JobEntity>> getJobs() async {
    final jobModels = await localDataSource.loadJobs();
    return jobModels;
  }

  @override
  Future<void> saveJobs(List<JobEntity> jobs) async {
    final jobModels = jobs.map((job) => JobModel.fromEntity(job)).toList();
    await localDataSource.saveJobs(jobModels);
  }

  @override
  Future<void> updateJob(JobEntity job) async {
    final jobs = await getJobs();
    final updatedJobs = jobs.map((j) => j.id == job.id ? job : j).toList();
    await saveJobs(updatedJobs);
  }

  @override
  Future<void> reOrderJobs(List<JobEntity> jobs) async {
    // Update the order property of each task based on its new position
    final reorderedTasks = jobs.asMap().entries.map((entry) {
      final index = entry.key;
      final task = entry.value;
      return task.copyWith(order: index);
    }).toList();

    await saveJobs(reorderedTasks);
  }

  @override
  Future<void> clearCompletedJobs() async {
    final tasks = await getJobs();
    final remainingTasks = tasks
        .where((task) => task.status != JobStatus.completed)
        .toList();

    // Reorder the remaining tasks
    final reorderedTasks = remainingTasks.asMap().entries.map((entry) {
      final index = entry.key;
      final task = entry.value;
      return task.copyWith(order: index);
    }).toList();

    await saveJobs(reorderedTasks);
  }

  @override
  Future<void> resetAllJobs() async {
    final tasks = await getJobs();
    final resetTasks = tasks
        .map(
          (task) => task.copyWith(
            status: JobStatus.pending,
            progress: 0.0,
            startedAt: null,
            completedAt: null,
          ),
        )
        .toList();

    await saveJobs(resetTasks);
  }
}
