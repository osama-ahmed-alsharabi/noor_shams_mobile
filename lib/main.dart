import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/light_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repo_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/splash/presentation/view/splash_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cclheqtkkilshiporyap.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNjbGhlcXRra2lsc2hpcG9yeWFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY4Mzk4NjgsImV4cCI6MjA4MjQxNTg2OH0.6aKaPgFoB3FvaHmb1RxJ1Hd8Ylv_jmxz4IHkTSQODcM',
  );

  final supabase = Supabase.instance.client;
  final authDataSource = AuthRemoteDataSourceImpl(supabase);
  final authRepository = AuthRepositoryImpl(authDataSource);
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final authCubit = AuthCubit(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
  );

  runApp(NoorShamsApp(authCubit: authCubit));
}

class NoorShamsApp extends StatelessWidget {
  final AuthCubit authCubit;

  const NoorShamsApp({super.key, required this.authCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authCubit,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Noor Shams',
        theme: light(),
        home: const SplashView(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
