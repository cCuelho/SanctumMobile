import 'package:flutter_test/flutter_test.dart';

import 'package:sanctum_mobile/api/sanctum_api_client.dart';
import 'package:sanctum_mobile/config.dart';

void main() {
  test('healthCheck returns false for invalid host', () async {
    final client = SanctumApiClient(
      SanctumConfig(apiBaseUrl: 'http://127.0.0.1:1'),
    );
    addTearDown(client.close);
    expect(await client.healthCheck(), isFalse);
  });
}
