import 'package:flutter_test/flutter_test.dart';
import 'package:onedash/core/network/api_compatibility.dart';
import 'package:onedash/core/network/network_exceptions.dart';

void main() {
  test('clearScope drops remembered endpoint order', () async {
    final scope = Object();
    var firstCalls = 0;
    var secondCalls = 0;

    Future<String> run() => ApiCompatibility.tryVariants<String>(
      [
        ApiEndpointVariant(
          name: 'first',
          call: () async {
            firstCalls++;
            throw const HttpException('missing', statusCode: 404);
          },
        ),
        ApiEndpointVariant(
          name: 'second',
          call: () async {
            secondCalls++;
            return 'ok';
          },
        ),
      ],
      cacheScope: scope,
      cacheKey: 'endpoint',
    );

    expect(await run(), 'ok');
    expect((firstCalls, secondCalls), (1, 1));
    expect(await run(), 'ok');
    expect((firstCalls, secondCalls), (1, 2));

    ApiCompatibility.clearScope(scope);

    expect(await run(), 'ok');
    expect((firstCalls, secondCalls), (2, 3));
  });

  test('auth errors do not fall through to a legacy endpoint', () async {
    var secondCalls = 0;
    await expectLater(
      ApiCompatibility.tryVariants<String>([
        ApiEndpointVariant(
          name: 'new',
          call: () async =>
              throw const AuthException('unauthorized', statusCode: 401),
        ),
        ApiEndpointVariant(
          name: 'legacy',
          call: () async {
            secondCalls++;
            return 'ok';
          },
        ),
      ]),
      throwsA(isA<AuthException>()),
    );
    expect(secondCalls, 0);
  });
}
