part of './Extensions.dart';


///Nullable String
extension StringNExtension on String? {
  /// check valid string
  bool get isValid => (this ?? '').isValid;
}

// ignore: public_member_api_docs
extension StringExtension on String {
  ///Returns the given text by only making the first character in capital and rest in lowe case.
  String get upperCaseFirst {
    if (length > 1) {
      return '${this[0].toUpperCase()}${substring(1, length).toLowerCase()}';
    } else {
      return this;
    }
  }

  ///Puts the given String inside qutation
  String get quoted => '❝$this❞';

  ///Removes all the special characters from the given String
  String get filtered {
    return replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('*', '')
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll('#', '')
        .replaceAll('\n', '')
        .replaceAll('!', '')
        .replaceAll('[', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(']', '');
  }

  ///If the string is empty, then it will be returned null
  String? get nullable => ifValid();

  ///Returns a valid [String] which has characters length greater than [1] and not equal to ["null"]
  ///Otherwise [null] will be returned.
  ///Used on [UI] [Add] [Edit] page [Txtfield] values
  ///If minimum length is given, then any text which is less than [minLength] will be returned as [null]
  String? ifValid({int minLength = 1}) {
    final String _text = trim();
    bool isValid = _text.characters.isNotEmpty && _text != 'null';
    isValid = _text.length >= minLength;
    return isValid ? _text : null;
  }

  ///Returns only if the given input is a valid url.
  ///Note: you can pass a [Json] and it's [key] to parse the [value]
  ///or you can pass the [String] as direct input
  static String? validatedUrl(Object? stringOrJson, [String? key]) {
    String finalInput = '';
    if (stringOrJson is Json) {
      finalInput = '${stringOrJson[key]}';
    } else {
      finalInput = '$stringOrJson';
    }
    final bool isValid = finalInput.contains('http') && finalInput.contains('.');
    return isValid ? finalInput : null;
  }

  ///Parses int? from the given String
  int? get toInt => int.tryParse(this);

  ///If this String is not only empty space and contains some text
  ///to be considered as valid String
  bool get isValid => trim().isNotEmpty;

  ///Checks if this string is a valid Email
  bool get isValidEmail => contains('@') && contains('.') && length > 5;

  ///This function converts the given String which is in camelCase
  String get camelCaseToString {
    // Use a regular expression to insert a space before each capital letter
    return replaceAllMapped(RegExp(r'([A-Z])'), (Match match) {
      return ' ${match.group(0)}';
    });
  }

  ///This will hide half of the email address with ***
  String get hideEmail {
    final List<String> splitEmail = split('@');
    if (splitEmail.isEmpty) {
      return this;
    }
    final String hiddenPart = splitEmail[0].substring(0, splitEmail[0].length ~/ 2);
    final String visiblePart = splitEmail[0].substring(splitEmail[0].length ~/ 2);
    final String hiddenEmail = '$hiddenPart${'*' * visiblePart.length}@${splitEmail[1]}';
    return hiddenEmail;
  }

}
