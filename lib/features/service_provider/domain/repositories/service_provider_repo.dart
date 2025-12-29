import 'package:dartz/dartz.dart';
import '../../domain/entities/service_provider_entity.dart';

abstract class ServiceProviderRepo {
  Future<Either<String, ServiceProviderEntity>> getProviderProfile(String uid);
  Future<Either<String, void>> updateProviderProfile(
    ServiceProviderEntity provider,
  );
}
