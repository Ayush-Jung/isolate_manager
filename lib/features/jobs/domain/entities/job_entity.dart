import 'package:equatable/equatable.dart';
import 'package:shring_tech/features/jobs/data/models/job_model.dart';

enum JobStatus { pending, running, completed, paused }

class JobEntity extends Equatable {
  final String id;
  final String title;
  final JobStatus status;
  final int order;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double progress;

  const JobEntity({
    required this.id,
    required this.title,
    required this.status,
    required this.order,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.progress = 0.0,
  });

  JobModel fromEntity() {
    return JobModel(
      id: id,
      title: title,
      status: status,
      order: order,
      createdAt: createdAt,
      startedAt: startedAt,
      completedAt: completedAt,
      progress: progress,
    );
  }

  JobEntity copyWith({
    String? id,
    String? title,
    JobStatus? status,
    int? order,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? progress,
  }) {
    return JobEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    status,
    order,
    createdAt,
    startedAt,
    completedAt,
    progress,
  ];
}
