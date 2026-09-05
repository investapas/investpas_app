part of './Extensions.dart';

// ignore: public_member_api_docs
extension DoubleExtensions on double {
  ///For this project, the gold and currency accuracy must be 3 digit precise
  ///asked by client
  ///Converts the given double value to [12.541] format
  double get toFixedDigit {
    return double.tryParse(toStringAsFixed(Widgets.decimalPlace)) ?? toDouble();
  }

  ///Returns the given value in the format of [25%]
  String get toPercentage => '${fixedDigit(decimalPlace: 2)}%';

  ///It does the same job similar to toFixedDigit, but it accepts parameters, so we can use it anywhere.
  String fixedDigit({required int decimalPlace}) {
    final double dbl = toFixedDigit;
    // Convert the double to a string with the specified decimal places
    final String formattedCurrency = dbl.toStringAsFixed(decimalPlace);

    // Split the formatted string into its integer and fractional parts
    final List<String> parts = formattedCurrency.split('.');
    final String integerPart = parts[0];
    String fractionalPart = parts.length > 1 ? parts[1] : '';

    // Add trailing zeros if necessary
    if (fractionalPart.length < decimalPlace) {
      fractionalPart = fractionalPart.padRight(decimalPlace, '0');
    }

    // Combine the integer and fractional parts to form the currency string
    final String result = integerPart + (fractionalPart.isNotEmpty ? '.$fractionalPart' : '');

    return result;
  }

  ///Converts the given double with fixed decimals without currency symbol
  String get toFixedDigitString => fixedDigit(decimalPlace: Widgets.decimalPlace);

  ///Returns the given double as fixed decimals with currency symbol
  String get toCurrency => '${Widgets.currencySymbol} $toFixedDigitString';
}
