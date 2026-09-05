
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme/data.dart';

/// local dropdown
class LocalDropdown extends StatelessWidget {
  /// constructor
  const LocalDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
            value: context.locale,
            items:  [
              DropdownMenuItem(value: const Locale('en'), child: Text('English',
              style: TextStyle(color: AppThemeData.textColor,)),),
              const DropdownMenuItem(value:  Locale('as'), child: Text('Assamese')),
              const DropdownMenuItem(value: Locale('bn'), child: Text('Bengali')),
              const DropdownMenuItem(value: Locale('hi'), child: Text('Hindi')),
            ],
            onChanged: (Locale? locale) {
              if (locale != null) {
                context.setLocale(locale);
                
              }
            },
          );
  }
}
