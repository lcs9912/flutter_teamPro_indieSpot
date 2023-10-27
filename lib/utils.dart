import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String password) {
  var bytes = utf8.encode(password); // Convert the string to bytes
  var digest = sha256.convert(bytes); // Calculate the hash
  return digest.toString(); // Return the hash as a string
}
