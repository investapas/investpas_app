import 'dart:convert' as convert;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../Extensions/Extensions.dart';
import '../../../Widgets/Widgets.dart';
import '../../../core/constants/constants.dart';


/// A class representing parsed HTTP data,status code, message in a nutshell
class HttpResult extends Equatable {
  ///Response code sent by the server
  final int code;

  ///Response message sent by the server
  final String? message;

  ///Response in the form of String
  final String responseString;

  ///Constructor
  const HttpResult({
    this.code = 0,
    this.message = 'No message returned!',
    this.responseString = '{}',
  });

  ///This parses the HttpResponse and returns a HttpResult class which contains all the information required by the front end files!
  factory HttpResult.create({
    required int code,
    required String? message,

    ///This responseString is encrypted
    required String responseString,
  }) {
    // Widgets.print('responseString: $responseString');
  
    final HttpResult result = HttpResult(
      code: code,
      message: message,
      responseString: responseString,
    );
    return result;
  }

  ///If the performed operation is completed then the status code will be 200
  bool get isSuccess => code == 201 || code == 200;

  dynamic get _convertedResult => convert.json.decode(responseString);

  List<String> get _characters => '$_convertedResult'.characters.toList();

  ///To check if the response is a [Json]
  bool get isJson => _characters.first == '{' && _characters.last == '}';

  ///To check if the response is a [List]
  bool get isList => _characters.first == '[' && _characters.last == ']';

  ///Returns the result as List<dynamics>
  List<dynamic> get list {
    if (isSuccess && isList) {
      return (_convertedResult ?? <dynamic>[]) as List<dynamic>;
    } else {
      return <dynamic>[];
    }
  }

  ///Returns the result as Json
  Json get json {
    if (isSuccess && isJson) {
      return (_convertedResult ?? <String>{}) as Json;
    } else {
      return <String, dynamic>{};
    }
  }

  ///Used to show Toast message on error.

  void showToastOnError() {
    String? customErrorMessage;
    print('isJson: $isJson');
    if (isJson) {
      ///If custom "error" text is given inside JSON that will be used
      customErrorMessage = (_convertedResult as Json).nullableString('errorMessage');
    }
    //Otherwise, error from the actual scene ie from db or server will be shown
    final String _m = customErrorMessage ?? (Widgets.debugMode ? '($code) $message' : '$message');
    if (isSuccess == false) {
      Widgets.showToast(_m);
    }
  }

  ///Returns the HttpResult to a readable [Json] format
  Json get toJson => <String, dynamic>{
        'code': code,
        'message': message,
        'responseString': responseString,
        'json': json,
        'list': list,
      };

  @override
  List<dynamic> get props => <dynamic>[
        code,
        message,
        responseString,
      ];

  @override
  String toString() {
    return toJson.toString();
  }
}
