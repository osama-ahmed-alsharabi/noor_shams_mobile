import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String role,
  );
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed: User is null');
    }

    // Fetch user details from public.users table
    final userData = await supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name, 'role': role}, // Optional: metadata
    );

    if (response.user == null) {
      throw Exception('Registration failed: User is null');
    }

    // Insert user into public.users table manually
    // (Note: Ideally, a Trigger would handle this, but per requirement we handle it here or ensure it matches schema)
    final userData = {
      'id': response.user!.id,
      'name': name,
      'email': email,
      'role': role,
    };

    await supabase.from('users').insert(userData);

    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final userData = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(userData);
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
