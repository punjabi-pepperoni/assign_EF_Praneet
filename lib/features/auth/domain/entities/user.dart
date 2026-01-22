import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String email;
  final String accessToken;
  final String refreshToken;

  const User({
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object> get props => [email, accessToken, refreshToken];
}
