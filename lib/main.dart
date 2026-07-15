import 'package:flutter/material.dart';

import 'app.dart';
import 'integration_test/bootstrap.dart';
import 'services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IntegrationTestBootstrap.install();
  await AppServices.init();
  runApp(const SanctumApp());
}
