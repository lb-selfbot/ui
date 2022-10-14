import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lightningui/utils.dart';

class APIResult {
  APIResult({
    required this.success,
    required this.response,
    required this.json,
  });

  final bool success;
  final http.Response? response;
  final Map<String, dynamic> json;
}

class UserData {
  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
    required this.isTester,
    required this.accountType,
    required this.logins,
    required this.dateJoined,
    required this.loginTime,
    required this.key,
    required this.freeTrialExpiry,
    required this.lastSelfbotLogin,
  });

  final int id;
  final String username;
  final String email;
  final bool isStaff;
  final bool isTester;
  final String accountType;
  final int logins;
  final DateTime dateJoined;
  final DateTime loginTime;
  final String key;
  final DateTime freeTrialExpiry;
  final DateTime lastSelfbotLogin;
}

class Stats {
  Stats({
    required this.auth,
    required this.version,
    required this.globalLogins,
  });

  final String auth;
  final String version;
  final int globalLogins;
}

class API {
  static const String baseUrl = "http://localhost:8000";

  static UserData? userData;
  static Stats? stats;

  static Future<Map<String, dynamic>> getJson(String path) async {
    final response = await http.get(Uri.parse("$baseUrl$path"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to get $path");
    }
  }

  static Future<http.Response> postJson(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
        ...?headers,
      },
      body: json.encode(body),
      encoding: encoding,
    );
  }

  static Future<APIResult> auth(String username, String password) async {
    return Future.delayed(
      const Duration(seconds: 1),
      () {
        userData = UserData(
          id: 5,
          username: "Lightning",
          email: "Email",
          isStaff: true,
          isTester: true,
          accountType: "Lifetime",
          logins: 8742,
          dateJoined: DateTime.parse("2020-02-27"),
          loginTime: DateTime.parse("2020-02-27"),
          key: "LB-ABCD-EFGH-IJKL",
          freeTrialExpiry: DateTime.parse("2020-02-27"),
          lastSelfbotLogin: DateTime.parse("2020-02-27"),
        );
        stats = Stats(
          auth: "Online",
          version: "4.0.0",
          globalLogins: 98711,
        );
        return APIResult(success: true, response: null, json: {});
      },
    );
    http.Response response;
    try {
      response = await postJson(
        "/api/v3/auth/auth",
        body: {
          "username": username,
          "password": password,
          "client_type": "ui",
        },
      );
    } catch (e) {
      return APIResult(success: false, response: null, json: {});
    }

    final result = APIResult(
      success: response.statusCode == 200,
      response: response,
      json: Utils.tryDecode(response.body),
    );

    if (result.success) {
      userData = UserData(
        id: result.json["id"] as int,
        username: result.json["username"] as String,
        email: result.json["email"] as String,
        isStaff: result.json["is_staff"] as bool,
        isTester: result.json["is_tester"] as bool,
        accountType: result.json["account_type"] as String,
        logins: result.json["logins"] as int,
        dateJoined: DateTime.parse(result.json["date_joined"] as String),
        loginTime: DateTime.parse(result.json["login_time"] as String),
        key: result.json["key"] as String,
        freeTrialExpiry:
            DateTime.parse(result.json["free_trial_expiry"] as String),
        lastSelfbotLogin:
            DateTime.parse(result.json["last_selfbot_login"] as String),
      );
    }

    return result;
  }
}
