import 'package:dartz/dartz.dart';
import '../repositories/auth_repo.dart';
import '../entities/user_entity.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<String, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    return await repository.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}
