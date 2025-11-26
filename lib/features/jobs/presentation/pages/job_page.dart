import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';
import 'package:shring_tech/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:shring_tech/features/jobs/presentation/bloc/job_event.dart';
import 'package:shring_tech/features/jobs/presentation/bloc/job_state.dart';
import 'package:shring_tech/features/jobs/presentation/widgets/job_action_widget.dart';
import 'package:shring_tech/features/jobs/presentation/widgets/job_card.dart';

class JobQueuePage extends StatelessWidget {
  const JobQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Queue Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: BlocConsumer<JobBloc, JobsState>(
        listener: (context, state) {
          if (state is JobsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is JobsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is JobsLoaded) {
            return Column(
              children: [
                _buildStatusHeader(state),
                Expanded(child: _buildJobList(context, state.jobs)),
                JobActionWidget(
                  isProcessing: state.isProcessing,
                  isPaused: state.isPaused,
                  onStart: () => context.read<JobBloc>().add(StartProcessing()),
                  onPause: () => context.read<JobBloc>().add(PauseProcessing()),
                  onResume: () =>
                      context.read<JobBloc>().add(ResumeProcessing()),
                  onStop: () => context.read<JobBloc>().add(StopProcessing()),
                  onClearCompleted: () =>
                      context.read<JobBloc>().add(ClearCompletedJobsEvent()),
                  onResetAll: () =>
                      context.read<JobBloc>().add(ResetAllJobsEvent()),
                ),
              ],
            );
          } else if (state is JobsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<JobBloc>().add(LoadJobs()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Welcome to Task Queue Manager'));
        },
      ),
    );
  }

  // handle current queue job
  Widget _buildStatusHeader(JobsLoaded state) {
    final completedCount = state.jobs
        .where((job) => job.status == JobStatus.completed)
        .length;
    final totalCount = state.jobs.length;
    final currentJobTitle = state.currentJobs?.title ?? 'None';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Queue Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Progress',
                  '$completedCount / $totalCount',
                  Icons.pie_chart,
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  'Status',
                  state.isProcessing
                      ? (state.isPaused ? 'Paused' : 'Running')
                      : 'Stopped',
                  state.isProcessing
                      ? (state.isPaused ? Icons.pause : Icons.play_arrow)
                      : Icons.stop,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusItem(
            'Current Job',
            currentJobTitle,
            Icons.task_alt,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String label,
    String value,
    IconData icon, {
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: SizedBox(
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '$label: ',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // listing jobs if available
  Widget _buildJobList(BuildContext context, List<JobEntity> jobs) {
    if (jobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No jobs available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: jobs.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final job = jobs.removeAt(oldIndex);
        jobs.insert(newIndex, job);
        context.read<JobBloc>().add(ReorderJobsEvent(jobs));
      },
      itemBuilder: (context, index) {
        final job = jobs[index];
        return JobCard(key: ValueKey(job.id), job: job);
      },
    );
  }
}
