
import 'dart:convert';

import 'package:crypto/crypto.dart';

/// crypto service
class CryptoService {
  CryptoService._();

  /// Generates a SHA-256 hash of the given input string.
  ///
  /// Parameters:
  /// - input: The string to be hashed.
  ///
  /// Returns:
  /// - A string representing the SHA-256 hash of the input string.
 static String generateSHA256Hash(String input) {
  final bytes = utf8.encode(input); // Convert input to bytes
  final digest = sha256.convert(bytes); // Hash the bytes
  
  return digest.toString(); // Convert hash to string
}
}
