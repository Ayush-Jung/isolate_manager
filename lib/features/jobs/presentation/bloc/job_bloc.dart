import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shring_tech/core/usecases/usecase.dart';
import 'package:shring_tech/core/utilities/job_isolate_manager.dart';
import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';
import 'package:shring_tech/features/jobs/domain/usecases/clear_jobs_usecase.dart';
import 'package:shring_tech/features/jobs/domain/usecases/get_jobs_usecase.dart';
import 'package:shring_tech/features/jobs/domain/usecases/re_order_jobs_usecase.dart';
import 'package:shring_tech/features/jobs/domain/usecases/reset_all_jobs_usecase.dart';
import 'package:shring_tech/features/jobs/domain/usecases/update_jobs_usecase.dart';
import 'package:shring_tech/features/jobs/presentation/bloc/job_event.dart';
import 'package:shring_tech/features/jobs/presentation/bloc/job_state.dart';
import 'package:collection/collection.dart';

class JobBloc extends Bloc<JobEvent, JobsState> {
  final GetJobs getJobs;
  final UpdateJob updateJob;
  final ReorderJobs reorderJobs;
  final ClearCompletedJobs clearCompletedJobs;
  final ResetAllJobs resetAllJobs;

  StreamSubscription<JobProcessorManager>? _processorSubscription;
  List<JobEntity> _currentJobs = [];
  bool _isProcessing = false;
  bool _isPaused = false;
  JobEntity? _currentJob;

  JobBloc({
    required this.getJobs,
    required this.updateJob,
    required this.reorderJobs,
    required this.clearCompletedJobs,
    required this.resetAllJobs,
  }) : super(JobsInitial()) {
    on<LoadJobs>(_onLoadJobs);
    on<StartProcessing>(_onStartProcessing);
    on<PauseProcessing>(_onPauseProcessing);
    on<ResumeProcessing>(_onResumeProcessing);
    on<StopProcessing>(_onStopProcessing);
    on<ReorderJobsEvent>(_onReorderTasks);
    on<ClearCompletedJobsEvent>(_onClearCompletedJobs);
    on<ResetAllJobsEvent>(_onResetAllJobs);
    on<JobProgressUpdatedEvent>(_onJobProgressUpdated);
    on<JobStatusUpdatedEvent>(_onJobStatusUpdated);
    on<PauseJobQueue>(_onPauseQueueLoaded);
    on<ResumeJobQueue>(_onResumeJobLoaded);
    _setupProcessorListener();
  }

  void _onPauseQueueLoaded(PauseJobQueue event, Emitter<JobsState> emit) {
    emit(event.jobsLoaded);
  }

  void _onResumeJobLoaded(ResumeJobQueue event, Emitter<JobsState> emit) {
    emit(event.jobsLoaded);
  }

  void _setupProcessorListener() {
    log('Setting up processor listener');
    _processorSubscription = TaskProcessor.messageStream.listen((message) {
      log('Received message from isolate: ${message.type}');
      switch (message.type) {
        case 'JOB_STARTED':
          final jobId = message.data['id'];
          add(JobStatusUpdatedEvent(jobId, JobStatus.running));
          break;
        case 'JOB_PROGRESS':
          final jobId = message.data['id'];
          final progress = message.data['progress'];
          add(JobProgressUpdatedEvent(jobId, progress));
          break;
        case 'JOB_COMPLETED':
          final jobId = message.data['id'];
          add(JobStatusUpdatedEvent(jobId, JobStatus.completed));
          _processNextTask();
          break;
        case 'PAUSED':
          _isPaused = true;
          add(
            PauseJobQueue(
              JobsLoaded(
                jobs: _currentJobs,
                isProcessing: _isProcessing,
                isPaused: _isPaused,
                currentJobs: _currentJob,
              ),
            ),
          );

          break;
        case 'RESUMED':
          _isPaused = false;
          add(
            ResumeJobQueue(
              JobsLoaded(
                jobs: _currentJobs,
                isProcessing: _isProcessing,
                isPaused: _isPaused,
                currentJobs: _currentJob,
              ),
            ),
          );
          break;
      }
    });
  }

  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobsState> emit) async {
    try {
      emit(JobsLoading());
      List<JobEntity> dbJobs = await getJobs(NoParams());
      _currentJobs = dbJobs;
      emit(
        JobsLoaded(
          jobs: dbJobs,
          isProcessing: _isProcessing,
          isPaused: _isPaused,
          currentJobs: _currentJob,
        ),
      );
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> _onStartProcessing(
    StartProcessing event,
    Emitter<JobsState> emit,
  ) async {
    if (_isProcessing) return;

    _isProcessing = true;
    _isPaused = false;
    await TaskProcessor.start();
    _processNextTask();
    emit(
      JobsLoaded(
        jobs: _currentJobs,
        isProcessing: _isProcessing,
        isPaused: _isPaused,
        currentJobs: _currentJob,
      ),
    );
  }

  Future<void> _onPauseProcessing(
    PauseProcessing event,
    Emitter<JobsState> emit,
  ) async {
    if (!_isProcessing || _isPaused) return;

    await TaskProcessor.pauseProcessing();
  }

  Future<void> _onResumeProcessing(
    ResumeProcessing event,
    Emitter<JobsState> emit,
  ) async {
    if (!_isProcessing || !_isPaused) return;

    await TaskProcessor.resumeProcessing();
  }

  void _onStopProcessing(StopProcessing event, Emitter<JobsState> emit) {
    if (!_isProcessing) return;

    _isProcessing = false;
    _isPaused = false;
    _currentJob = null;
    TaskProcessor.stop();
    emit(
      JobsLoaded(
        jobs: _currentJobs,
        isProcessing: _isProcessing,
        isPaused: _isPaused,
        currentJobs: _currentJob,
      ),
    );
  }

  Future<void> _onReorderTasks(
    ReorderJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      await reorderJobs(ReorderJobsParams(jobs: event.jobs));
      _currentJobs = event.jobs;
      emit(
        JobsLoaded(
          jobs: _currentJobs,
          isProcessing: _isProcessing,
          isPaused: _isPaused,
          currentJobs: _currentJob,
        ),
      );
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> _onClearCompletedJobs(
    ClearCompletedJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      await clearCompletedJobs(NoParams());
      final jobs = await getJobs(NoParams());
      _currentJobs = jobs;
      emit(
        JobsLoaded(
          jobs: _currentJobs,
          isProcessing: _isProcessing,
          isPaused: _isPaused,
          currentJobs: _currentJob,
        ),
      );
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> _onResetAllJobs(
    ResetAllJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    try {
      await resetAllJobs(NoParams());
      final tasks = await getJobs(NoParams());
      _currentJobs = tasks;
      _currentJob = null;
      emit(
        JobsLoaded(
          jobs: _currentJobs,
          isProcessing: _isProcessing,
          isPaused: _isPaused,
          currentJobs: _currentJob,
        ),
      );
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> _onJobProgressUpdated(
    JobProgressUpdatedEvent event,
    Emitter<JobsState> emit,
  ) async {
    final updatedJobs = _currentJobs.map((job) {
      if (job.id == event.jobId) {
        final updatedJob = job.copyWith(progress: event.progress);
        return updatedJob;
      }
      return job;
    }).toList();

    _currentJobs = updatedJobs;

    // Update the task in storage
    final taskToUpdate = updatedJobs.firstWhere((job) => job.id == event.jobId);
    await updateJob(UpdateJobParams(job: taskToUpdate));

    final newState = JobsLoaded(
      jobs: _currentJobs,
      isProcessing: _isProcessing,
      isPaused: _isPaused,
      currentJobs: _currentJob,
    );
    emit(newState);
  }

  Future<void> _onJobStatusUpdated(
    JobStatusUpdatedEvent event,
    Emitter<JobsState> emit,
  ) async {
    final updatedJobs = _currentJobs.map((job) {
      if (job.id == event.jobId) {
        final updatedJob = job.copyWith(status: event.status);
        if (event.status == JobStatus.running) {
          _currentJob = updatedJob;
        } else if (event.status == JobStatus.completed) {
          _currentJob = null;
        }
        return updatedJob;
      }
      return job;
    }).toList();

    _currentJobs = updatedJobs;

    // Update the task in storage
    final jobToUpdate = updatedJobs.firstWhere((job) => job.id == event.jobId);
    await updateJob(UpdateJobParams(job: jobToUpdate));

    emit(
      JobsLoaded(
        jobs: _currentJobs,
        isProcessing: _isProcessing,
        isPaused: _isPaused,
        currentJobs: _currentJob,
      ),
    );
  }

  void _processNextTask() {
    if (!_isProcessing || _isPaused) return;

    JobEntity? newJob;
    newJob = _currentJobs.firstWhereOrNull(
      (job) => job.status == JobStatus.pending,
    );
    if (newJob != null) {
      TaskProcessor.processTask(newJob);
    } else {
      print('All jobs completed, stopping processing');
      _isProcessing = false;
      _currentJob = null;
      TaskProcessor.stop();
    }
  }

  @override
  Future<void> close() {
    _processorSubscription?.cancel();
    TaskProcessor.stop();
    return super.close();
  }
}
