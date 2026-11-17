import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/dio_client.dart';

DioClient _client({String languageCode = 'zh'}) {
  return DioClient(
    baseUrl: 'https://panel.example.com',
    apiKey: 'key',
    userAgent: 'OneDash/test',
    languageCode: languageCode,
  );
}

void main() {
  test('sends the selected language in Accept-Language', () {
    final client = _client(languageCode: 'en');
    addTearDown(client.dispose);

    expect(client.raw.options.headers['Accept-Language'], 'en');
  });

  test('keeps Chinese as the default language', () {
    final client = _client();
    addTearDown(client.dispose);

    expect(client.raw.options.headers['Accept-Language'], 'zh');
  });
}
