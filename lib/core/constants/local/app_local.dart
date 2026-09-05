import 'package:flutter/material.dart';
import '../../../data/models/language.dart';

/// app languages
/// english
const Locale enLocale = Locale('en',);
/// assamese
const Locale asLocale = Locale('as');
/// hindi
const Locale hiLocale = Locale('hi');
/// bangla
const Locale bnLocale = Locale('bn');
//
/// laguages
const List<LanguageModel> kAppLanguages = [
  LanguageModel(
    locale: enLocale,
    name: 'English',
   
  ),
  LanguageModel(
    locale: asLocale,
    name: 'Assamese',
   
  ),
  LanguageModel(
    locale: hiLocale,
    name: 'Hindi',
   
  ),
  LanguageModel(
    locale: bnLocale,
    name: 'Bengali',
   
  ),
];
