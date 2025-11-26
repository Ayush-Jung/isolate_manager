import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shring_tech/core/utilities/injector.dart';
import 'package:shring_tech/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:shring_tech/features/jobs/presentation/bloc/job_event.dart';
import 'package:shring_tech/features/jobs/presentation/pages/job_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await injector.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider(
        create: (_) =>
            injector.getIt<JobBloc>()..add(LoadJobs()), // loading jobs at start
        child: const JobQueuePage(),
      ),
    );
  }
}
