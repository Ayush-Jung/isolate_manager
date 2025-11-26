import 'dart:convert';
import 'package:shring_tech/features/jobs/data/models/job_model.dart';
import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';
import 'package:shring_tech/utilities/local_storage.dart';

abstract class JobLocalDatasource {
  Future<List<JobModel>> loadJobs();
  Future<void> saveJobs(List<JobModel> jobs);
}

class JobLocalDatasourceImpl implements JobLocalDatasource {
  final AppStorage appStorage;
  JobLocalDatasourceImpl(this.appStorage);

  @override
  Future<List<JobModel>> loadJobs() async {
    final list = appStorage.sharedPreferences.getStringList("my_jobs") ?? [];
    if (list.isEmpty) {
      List<JobModel> dbJobs = [];
      //generate fake jobs
      for (int i = 1; i <= 12; i++) {
        final newJob = JobModel(
          id: 'job_$i',
          title: 'Job $i',
          status: JobStatus.pending,
          progress: 0.0,
          createdAt: DateTime.now(),
          order: i,
        );
        dbJobs.add(newJob);
      }
      return dbJobs;
    }
    return list
        .map(
          (e) => JobModel.fromJson(Map<String, dynamic>.from(json.decode(e))),
        )
        .toList();
  }

  @override
  Future<void> saveJobs(List<JobModel> jobs) async {
    await appStorage.sharedPreferences.setStringList(
      "my_jobs",
      jobs.map((e) => json.encode(e.toJson())).toList(),
    );
  }
}
