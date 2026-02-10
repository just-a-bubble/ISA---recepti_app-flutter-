import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      contentType: 'application/json',
      validateStatus: (_) => true,
    ),
  )..interceptors.add(
      CookieManager(CookieJar()),
    );

  /// Nastavi baseUrl glede na IP
  static Future<void> setBaseUrl(String ip) async {
    final prefs = await SharedPreferences.getInstance();

    final cleanIp = ip.replaceAll('http://', '').trim();
    final baseUrl = 'http://$cleanIp:8000/api';

    dio.options.baseUrl = baseUrl;
    await prefs.setString('base_url', baseUrl);
  }

  /// Naloži baseUrl ob zagonu aplikacije
  static Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('base_url');

    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }
  }
}
