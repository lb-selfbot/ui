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
  final int loginTime;
  final String key;
  final int freeTrialExpiry;
  final DateTime lastSelfbotLogin;
}

class Stats {
  Stats({
    required this.auth,
    required this.version,
    required this.users,
    required this.logins,
  });

  final String auth;
  final String version;
  final int users;
  final int logins;
}

class API {
  static const String baseUrl = "https://api.lightning-bot.com";

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
      final user = result.json["user"];

      userData = UserData(
        id: user["id"] as int,
        username: user["username"] as String,
        email: user["email"] as String,
        isStaff: user["is_staff"] as bool,
        isTester: user["is_tester"] as bool,
        accountType: user["account_type"] as String,
        logins: user["logins"] as int,
        dateJoined: DateTime.parse(user["date_joined"] as String),
        loginTime: user["login_time"] as int,
        key: user["key"] as String,
        freeTrialExpiry: user["free_trial_expiry"] as int,
        lastSelfbotLogin:
            DateTime.parse(user["last_selfbot_login"] ?? "1970-01-01"),
      );

      final statsJson = result.json["stats"];

      stats = Stats(
        auth: statsJson["auth"] as String,
        version: statsJson["version"] as String,
        users: statsJson["users"] as int,
        logins: statsJson["logins"] as int,
      );
    }

    return result;
  }

  static Future<APIResult> checkVersion(String branch, String version) async {
    http.Response response;
    try {
      response = await postJson(
        "/api/v3/selfbot/check-version",
        body: {
          "branch": branch,
          "version": version,
        },
      );
    } catch (e) {
      return APIResult(success: false, response: null, json: {});
    }

    return APIResult(
      success: response.statusCode == 200,
      response: response,
      json: Utils.tryDecode(response.body),
    );
  }
}
