import 'package:flutter/widgets.dart';

import 'app.dart';
import 'services/firebase_bootstrap_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrapService.instance.initialize();
  runApp(const GaanfyApp());
}
