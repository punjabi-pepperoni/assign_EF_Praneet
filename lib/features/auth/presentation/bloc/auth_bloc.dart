import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
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
  }
}
