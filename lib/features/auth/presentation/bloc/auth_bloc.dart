import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/google_sign_in.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../../../core/usecases/usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GoogleSignInUseCase googleSignIn;
  final Logout logout;
  final ForgotPassword forgotPassword;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.googleSignIn,
    required this.logout,
    required this.forgotPassword,
  }) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await loginUser(
          LoginParams(email: event.email, password: event.password));
      result.fold(
        (failure) =>
            emit(AuthFailure(message: failure.message ?? "Login Failed")),
        (user) => emit(AuthSuccess(user: user)),
      );
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await registerUser(
          RegisterParams(email: event.email, password: event.password));
      result.fold(
        (failure) => emit(
            AuthFailure(message: failure.message ?? "Registration Failed")),
        (user) => emit(AuthSuccess(user: user)),
      );
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await googleSignIn(NoParams());
      result.fold(
        (failure) => emit(
            AuthFailure(message: failure.message ?? "Google Sign-In Failed")),
        (user) => emit(AuthSuccess(user: user)),
      );
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await logout(NoParams());
      result.fold(
        (failure) =>
            emit(AuthFailure(message: failure.message ?? "Logout Failed")),
        (_) => emit(AuthLoggedOut()),
      );
    });

    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      final result =
          await forgotPassword(ForgotPasswordParams(email: event.email));
      result.fold(
        (failure) => emit(
            AuthFailure(message: failure.message ?? "Failed to send email")),
        (_) => emit(AuthForgotPasswordSuccess()),
      );
    });
  }
}
