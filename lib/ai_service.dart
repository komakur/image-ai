import 'package:dio/dio.dart';
import 'package:tmp/keys/keys.dart';

// singleton
class AiService {
  AiService._() : _dio = Dio();

  static AiService? _instance;

  static AiService get instance {
    _instance ??= AiService._();
    return _instance!;
  }

  final Dio _dio;

  Future<String> getAiImageByText({required String imageDescription}) async {
    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/images/generations',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Keys.apiKey}'
          },
        ),
        data: {
          "prompt": imageDescription,
          "n": 1,
          "size": "256x256",
        },
      );
      final String imageUrl = response.data['data'][0]['url'];
      return imageUrl;
    } on DioException catch (e) {
      print(e);
      rethrow;
    }
  }
}
