import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'package:shring_tech/features/jobs/domain/entities/job_entity.dart';

class JobProcessorManager {
  final String type;
  final Map<String, dynamic> data;

  JobProcessorManager({required this.type, required this.data});
}

class TaskProcessor {
  static Isolate? _isolate;
  static SendPort? _sendPort;
  static ReceivePort? _receivePort;
  static StreamController<JobProcessorManager>? _messageController;
  static bool _isProcessing = false;
  static bool _isPaused = false;

  static Stream<JobProcessorManager> get messageStream {
    _messageController ??= StreamController<JobProcessorManager>.broadcast();
    return _messageController!.stream;
  }

  static bool get isProcessing => _isProcessing;
  static bool get isPaused => _isPaused;

  static Future<void> start() async {
    if (_isolate != null) return;

    _receivePort ??= ReceivePort();
    _messageController ??= StreamController<JobProcessorManager>.broadcast();

    _isolate = await Isolate.spawn(_isolateEntryPoint, _receivePort!.sendPort);

    _receivePort!.listen((message) {
      log('Isolate sent message: $message');
      if (message is SendPort) {
        _sendPort = message;
      } else if (message is Map<String, dynamic>) {
        final jobMessage = JobProcessorManager(
          type: message['type'],
          data: Map<String, dynamic>.from(message['data']),
        );
        _messageController?.add(jobMessage); // add stream data
      }
    });
    // Wait for the isolate to be ready
    await Future.delayed(const Duration(milliseconds: 100));
  }

  static Future<void> processTask(JobEntity task) async {
    // if isolate not started, start it will start here first
    if (_sendPort == null) await start();

    _isProcessing = true;
    _sendPort?.send({
      'type': 'PROCESS_JOB',
      'data': {'id': task.id, 'title': task.title},
    });
  }

  static Future<void> pauseProcessing() async {
    if (_sendPort == null) return;

    _isPaused = true;
    _sendPort?.send({'type': 'PAUSE', 'data': {}});
  }

  static Future<void> resumeProcessing() async {
    if (_sendPort == null) return;

    _isPaused = false;
    _sendPort?.send({'type': 'RESUME', 'data': {}});
  }

  static void stop() async {
    if (_isolate == null) return;
    _sendPort?.send({'type': 'STOP'});
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _receivePort?.close();
    _receivePort = null;
    _isProcessing = false;
    _isPaused = false;
  }

  static void _isolateEntryPoint(SendPort mainSendPort) {
    final ReceivePort receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);
    bool isPaused = false;
    receivePort.listen((message) async {
      if (message is Map<String, dynamic>) {
        final type = message['type'];
        final data = message['data'];
        switch (type) {
          case 'PROCESS_JOB':
            if (!isPaused) {
              await _processJobInIsolate(mainSendPort, data, () => isPaused);
            }
            break;
          case 'PAUSE':
            isPaused = true;
            mainSendPort.send({'type': 'PAUSED', 'data': {}});
            break;
          case 'RESUME':
            isPaused = false;
            mainSendPort.send({'type': 'RESUMED', 'data': {}});
            break;
          case 'STOP':
            receivePort.close();
            break;
        }
      }
    });
  }

  static Future<void> _processJobInIsolate(
    SendPort mainSendPort,
    Map<String, dynamic> jobData,
    bool Function() isPausedCheck,
  ) async {
    final jobId = jobData['id'];
    // Notify that job started
    mainSendPort.send({
      'type': 'JOB_STARTED',
      'data': {'id': jobId},
    });

    // Simulate job processing with progress updates
    const totalSteps = 100;
    const stepDuration = Duration(
      milliseconds: 30,
    ); // 3 seconds total  100*30ms = 1 seconfd.

    for (int i = 0; i <= totalSteps; i++) {
      if (isPausedCheck()) {
        // Wait until resumed and check every 3 seconds
        while (isPausedCheck()) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      final progress = i / totalSteps;

      mainSendPort.send({
        'type': 'JOB_PROGRESS',
        'data': {'id': jobId, 'progress': progress},
      });

      if (i != totalSteps) {
        await Future.delayed(stepDuration);
      }
    }
    mainSendPort.send({
      'type': 'JOB_COMPLETED',
      'data': {'id': jobId},
    });
  }
}
