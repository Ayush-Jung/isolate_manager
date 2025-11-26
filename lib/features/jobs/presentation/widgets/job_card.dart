import 'package:flutter/material.dart';
import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';

class JobCard extends StatelessWidget {
  final JobEntity job;
  final VoidCallback? onReorder;

  const JobCard({super.key, required this.job, this.onReorder});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: _buildStatusIcon(),
        title: Text(
          job.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: job.status == JobStatus.completed ? Colors.grey[600] : null,
            decoration: job.status == JobStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildStatusBadge(),
            if (job.status == JobStatus.running || job.progress > 0) ...[
              const SizedBox(height: 8),
              _buildProgressBar(),
            ],
          ],
        ),
        trailing: ReorderableDragStartListener(
          index: job.order,
          child: const Icon(Icons.drag_handle, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (job.status) {
      case JobStatus.pending:
        return const Icon(Icons.schedule, color: Colors.orange);
      case JobStatus.running:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case JobStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case JobStatus.paused:
        return const Icon(Icons.pause_circle, color: Colors.blue);
    }
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;

    switch (job.status) {
      case JobStatus.pending:
        badgeColor = Colors.orange;
        statusText = 'Pending';
        break;
      case JobStatus.running:
        badgeColor = Colors.blue;
        statusText = 'Running';
        break;
      case JobStatus.completed:
        badgeColor = Colors.green;
        statusText = 'Completed';
        break;
      case JobStatus.paused:
        badgeColor = Colors.grey;
        statusText = 'Paused';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '${(job.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: job.progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            job.status == JobStatus.completed ? Colors.green : Colors.blue,
          ),
        ),
      ],
    );
  }
}
