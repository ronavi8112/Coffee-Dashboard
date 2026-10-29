import 'package:coffee_dashboard_viewer/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('config has a valid app title', () {
    expect(AppConfig.appTitle, isNotEmpty);
  });
}
