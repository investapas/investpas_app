part of 'login_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginOpenWebview extends LoginState {
  final String url;
  LoginOpenWebview(this.url);
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class NavigateToRegister extends LoginState {}
