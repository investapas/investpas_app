
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// languages state
class LanguagesState extends Equatable {
  /// locale
  final Locale locale;
/// constructor
  const LanguagesState({required this.locale});

  @override
  List<Object> get props => [locale];

  /// copyWith
  LanguagesState copyWith({Locale? locale}) {
    return LanguagesState(locale: locale ?? this.locale);
  }
}
