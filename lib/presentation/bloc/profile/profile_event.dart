import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ToggleAiAssistance extends ProfileEvent {
  final bool value;
  const ToggleAiAssistance(this.value);

  @override
  List<Object?> get props => [value];
}

class LoadUserPrefsEvent extends ProfileEvent {}

class LoadFundLimitEvent extends ProfileEvent {
  final bool silent;
  const LoadFundLimitEvent({this.silent = false});
}

class LoadProfileEvent extends ProfileEvent {}

class UploadProfilePictureEvent extends ProfileEvent {
  final String filePath;
  const UploadProfilePictureEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class RemoveProfilePictureEvent extends ProfileEvent {
  const RemoveProfilePictureEvent();
}