
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// languages event
class LanguagesEvent extends Equatable{

  @override
  List<Object?> get props => [];
}

/// change language event
class ChangeLanguageEvent extends LanguagesEvent{
  /// locale
 final Locale locale;
/// constructor
 ChangeLanguageEvent({required this.locale});
 @override
  List<Object?> get props => [locale];
}
