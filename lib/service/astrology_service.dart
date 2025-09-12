import 'package:dio/dio.dart';

class AstrologyService {
  static const String _baseUrl = 'https://json.freeastrologyapi.com';

  static const String _apiKey = 'eUDdpgqWBg3qoCMR0ZCOa6Aa2jPelgsy46bZF45h';

  static final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  static Future<void> getZodiacForToday() async {
    DateTime now = DateTime.now();

    final data = {"day": now.day, "month": now.month, "year": now.year};

    try {
      final response = await _dio.post(
        '/zodiac',
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        print("🪐 Today's Zodiac: ${result['zodiac']}");
      } else {
        print("❌ Error: ${response.statusCode}");
        print(response.data);
      }
    } catch (e) {
      print("❗ Exception: $e");
    }
  }
}
