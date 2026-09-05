part of 'login_bloc.dart';

abstract class LoginEvent {}

class LoginStarted extends LoginEvent {}

class LoginButtonPressed extends LoginEvent {}

class RegisterButtonPressed extends LoginEvent {}

class LoginCompleted extends LoginEvent {}

class ConsumeConsent extends LoginEvent {
  final String tokenId;
  ConsumeConsent(this.tokenId);
}