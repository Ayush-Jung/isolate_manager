import 'package:equatable/equatable.dart';
import 'package:shring_tech/features/jobs/presentation/bloc/job_state.dart';

import '../../domain/entities/job_entity.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object> get props => [];
}

class LoadJobs extends JobEvent {}

class StartProcessing extends JobEvent {}

class PauseProcessing extends JobEvent {}

class ResumeProcessing extends JobEvent {}

class StopProcessing extends JobEvent {}

class ReorderJobsEvent extends JobEvent {
  final List<JobEntity> jobs;

  const ReorderJobsEvent(this.jobs);

  @override
  List<Object> get props => [jobs];
}

class ClearCompletedJobsEvent extends JobEvent {}

class ResetAllJobsEvent extends JobEvent {}

class JobProgressUpdatedEvent extends JobEvent {
  final String jobId;
  final double progress;

  const JobProgressUpdatedEvent(this.jobId, this.progress);

  @override
  List<Object> get props => [jobId, progress];
}

class JobStatusUpdatedEvent extends JobEvent {
  final String jobId;
  final JobStatus status;

  const JobStatusUpdatedEvent(this.jobId, this.status);

  @override
  List<Object> get props => [jobId, status];
}

class ResumeJobQueue extends JobEvent {
  final JobsLoaded jobsLoaded;
  const ResumeJobQueue(this.jobsLoaded);
  @override
  List<Object> get props => [jobsLoaded];
}

class PauseJobQueue extends JobEvent {
  final JobsLoaded jobsLoaded;
  const PauseJobQueue(this.jobsLoaded);
  @override
  List<Object> get props => [jobsLoaded];
}
