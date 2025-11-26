import 'dart:convert';

import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.title,
    required super.status,
    required super.order,
    required super.createdAt,
    super.startedAt,
    super.completedAt,
    super.progress,
  });

  factory JobModel.fromEntity(JobEntity job) {
    return JobModel(
      id: job.id,
      title: job.title,
      status: job.status,
      order: job.order,
      createdAt: job.createdAt,
      startedAt: job.startedAt,
      completedAt: job.completedAt,
      progress: job.progress,
    );
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      title: json['title'],
      status: JobStatus.values[json['status']],
      order: json['order'],
      createdAt: DateTime.parse(json['createdAt']),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      progress: json['progress']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status.index,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  static List<JobModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => JobModel.fromJson(json)).toList();
  }

  static String toJsonList(List<JobModel> tasks) {
    final List<Map<String, dynamic>> jsonList = tasks
        .map((task) => task.toJson())
        .toList();
    return json.encode(jsonList);
  }

  @override
  JobModel copyWith({
    String? id,
    String? title,
    JobStatus? status,
    int? order,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? progress,
  }) {
    return JobModel(
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
}
