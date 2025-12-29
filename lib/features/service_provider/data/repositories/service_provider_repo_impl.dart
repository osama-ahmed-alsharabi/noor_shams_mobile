import 'package:dartz/dartz.dart';
import '../../domain/entities/service_provider_entity.dart';
import '../../domain/repositories/service_provider_repo.dart';
import '../datasources/service_provider_remote_datasource.dart';
import '../models/service_provider_model.dart';

class ServiceProviderRepoImpl implements ServiceProviderRepo {
  final ServiceProviderRemoteDataSource remoteDataSource;

  ServiceProviderRepoImpl(this.remoteDataSource);

  @override
  Future<Either<String, ServiceProviderEntity>> getProviderProfile(
    String uid,
  ) async {
    try {
      final result = await remoteDataSource.getProviderProfile(uid);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateProviderProfile(
    ServiceProviderEntity provider,
  ) async {
    try {
      final model = ServiceProviderModel.fromEntity(provider);
      await remoteDataSource.updateProviderProfile(model);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
