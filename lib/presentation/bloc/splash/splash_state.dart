part of 'splash_bloc.dart';

abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashCompleted extends SplashState {}

class SplashAuthenticate extends SplashState {}

// Authenticated but PIN not yet configured → go to SetupPinPage
class SplashNeedsPin extends SplashState {}

// Authenticated + PIN is set → show AppLockPage to unlock
class SplashShowLock extends SplashState {}