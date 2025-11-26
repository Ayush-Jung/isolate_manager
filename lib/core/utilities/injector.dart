import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shring_tech/features/jobs/data/datasources/job_local_datasource.dart';
import 'package:shring_tech/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:shring_tech/features/jobs/domain/repositories/job_repository.dart';
import 'package:shring_tech/features/jobs/domain/usecases/clear_jobs_usecase.dart';
import 'package:shring_tech/features/jobs/domain/usecases/get_jobs_usecase.dart';
import 'package:shring_tech/features/jobs/domain/usecases/re_order_jobs_usecase.dart';
import 'package:shring_tech/features/jobs/domain/usecases/reset_all_jobs_usecase.dart';
import 'package:shring_tech/features/jobs/domain/usecases/update_jobs_usecase.dart';
import 'package:shring_tech/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:shring_tech/utilities/local_storage.dart';

class ServiceInjector {
  final getIt = GetIt.instance;

  Future<void> initialize() async {
    final sharePref = await SharedPreferences.getInstance();

    // TODO: To clear local storage. Remove when done.
    // await sharePref.clear();

    getIt.registerLazySingleton<AppStorage>(
      () => AppStorage()..sharedPreferences = sharePref,
    );

    // Data sources
    getIt.registerLazySingleton<JobLocalDatasource>(
      () => JobLocalDatasourceImpl(getIt<AppStorage>()),
    );

    // Repositories
    getIt.registerLazySingleton<JobRepository>(
      () => getIt<JobRepositoryImpl>(),
    );
    getIt.registerLazySingleton<JobRepositoryImpl>(
      () => JobRepositoryImpl(localDataSource: getIt<JobLocalDatasource>()),
    );

    //usecases
    getIt.registerLazySingleton<ReorderJobs>(
      () => ReorderJobs(getIt<JobRepository>()),
    );

    getIt.registerLazySingleton<GetJobs>(() => GetJobs(getIt<JobRepository>()));

    getIt.registerLazySingleton<UpdateJob>(
      () => UpdateJob(getIt<JobRepository>()),
    );

    getIt.registerLazySingleton<ResetAllJobs>(
      () => ResetAllJobs(getIt<JobRepository>()),
    );

    getIt.registerLazySingleton<ClearCompletedJobs>(
      () => ClearCompletedJobs(getIt<JobRepository>()),
    );

    // bloc
    getIt.registerFactory(
      () => JobBloc(
        getJobs: getIt<GetJobs>(),
        updateJob: getIt<UpdateJob>(),
        reorderJobs: getIt<ReorderJobs>(),
        clearCompletedJobs: getIt<ClearCompletedJobs>(),
        resetAllJobs: getIt<ResetAllJobs>(),
      ),
    );
  }
}

final injector = ServiceInjector();
