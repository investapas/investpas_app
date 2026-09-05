import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../routes/appRoutes.dart';
import '../utils/navigationService.dart';
import '../utils/shared_prefs_helper.dart';
import '../utils/toast_helper.dart';

class ApiHelper {
  // static const String baseUrl = "https://dev.investapas.api.redoq.host";
  // static const String baseUrl = "http://192.168.1.7:3000";
  static const String baseUrl = "https://api.investapas.in";


  /// Common method to handle HTTP requests
  static Future<dynamic> request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
    String token = await sharedPrefsHelper.getToken() ?? "";
    final Uri url = Uri.parse("$baseUrl$endpoint");
    headers ??= {
      "Content-Type": "application/json",
      "Authorization": token,
    };
    print('url - $url body - $body , token $token -- ' );
    try {
      http.Response response;

      switch (method.toUpperCase()) {
        case "GET":
          Uri requestUrl = url;
          if (body != null) {
            final existingParams = requestUrl.queryParameters;
            final queryParameters = {
              ...existingParams,
              ...body.map((key, value) => MapEntry(key, value?.toString() ?? '')),
            };
            requestUrl = requestUrl.replace(queryParameters: queryParameters);
          }
          response = await http.get(requestUrl, headers: headers).timeout(Duration(seconds: 5));
          break;
        case "POST":
          response =
          await http.post(url, headers: headers, body: jsonEncode(body));
          break;
        case "PUT":
          response =
          await http.put(url, headers: headers, body: jsonEncode(body));
          break;
        case "DELETE":
          response = await http.delete(url, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        default:
          throw Exception("Invalid HTTP method: $method");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (!NavigatorService.isSessionEnded) {
          NavigatorService.markSessionEnded();
          await sharedPrefsHelper.clearUserData();
          NavigatorService.pushNamedAndRemoveUntil(AppRoutes.loginPage);
        }
        // ToastHelper.showToast(AppLocaleKeys.somethingWentWrong.tr(),
        //     isSuccess: false);
      } else if (response.statusCode == 500) {
        // ToastHelper.showToast(AppLocaleKeys.somethingWentWrong.tr(),
        //     isSuccess: false);
      } else {
        // ToastHelper.showToast(AppLocaleKeys.somethingWentWrong.tr(),
        //     isSuccess: false);
        throw Exception("Error: ${response.statusCode}, ${response.body}");
      }
    } on TimeoutException {
      ToastHelper.showToast("Timeout Error", isSuccess: false);
    } catch (e) {
      print("Api Failed $e");
      throw Exception("API Request Failed: $e");
    }
  }

  /// GET request
  static Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return await request(endpoint: endpoint, method: "GET", body: body, headers: headers);
  }

  /// POST request
  static Future<dynamic> post(String endpoint, Map<String, dynamic>? body,
      {Map<String, String>? headers}) async {


    return await request(
      endpoint: endpoint,
      method: "POST",
      body: body,
      headers: headers,
    );
  }

  // static Future<dynamic> post(String endpoint, Map<String, dynamic> body,
  //     {Map<String, String>? headers}) async {

  //   return await request(
  //       endpoint: endpoint, method: "POST", body: body, headers: headers);
  // }

  /// PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    return await request(
        endpoint: endpoint, method: "PUT", body: body, headers: headers);
  }

  /// DELETE request
  static Future<dynamic> delete(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return await request(
        endpoint: endpoint, method: "DELETE", body: body, headers: headers);
  }
}