import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configure les mocks pour les tests
class TestHelpers {
  /// Configure le mock pour SharedPreferences
  static Future<void> setUpSharedPreferences() async {
    // Configurer un mock pour SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Enregistrer un gestionnaire pour les exceptions MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getAll') {
              return {};
            }
            return null;
          },
        );
  }
}
