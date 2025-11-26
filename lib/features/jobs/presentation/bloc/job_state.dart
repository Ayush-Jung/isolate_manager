import 'package:equatable/equatable.dart';
import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';

abstract class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object> get props => [];
}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

class JobsLoaded extends JobsState {
  final List<JobEntity> jobs;
  final bool isProcessing;
  final bool isPaused;
  final JobEntity? currentJobs;

  const JobsLoaded({
    required this.jobs,
    this.isProcessing = false,
    this.isPaused = false,
    this.currentJobs,
  });

  JobsLoaded copyWith({
    List<JobEntity>? jobs,
    bool? isProcessing,
    bool? isPaused,
    JobEntity? currentJobs,
  }) {
    return JobsLoaded(
      jobs: jobs ?? this.jobs,
      isProcessing: isProcessing ?? this.isProcessing,
      isPaused: isPaused ?? this.isPaused,
      currentJobs: currentJobs ?? this.currentJobs,
    );
  }

  @override
  List<Object> get props => [jobs, isProcessing, isPaused, currentJobs ?? ''];
}

class JobsError extends JobsState {
  final String message;

  const JobsError(this.message);

  @override
  List<Object> get props => [message];
}
