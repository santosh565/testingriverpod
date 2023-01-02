import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_demo/state/auth/models/auth_result.dart';
import 'package:riverpod_demo/state/posts/typedefs/user_id.dart';

@immutable
class AuthState extends Equatable {
  final AuthResult? result;
  final bool isLoading;
  final UserId? userId;

  const AuthState(
      {required this.result, required this.isLoading, required this.userId});

  const AuthState.unknown()
      : result = null,
        isLoading = false,
        userId = null;

  AuthState copyWithIsLoading(bool isLoading) => AuthState(
        isLoading: isLoading,
        result: result,
        userId: userId,
      );

  @override
  List<Object?> get props => [result, isLoading, userId];
}
