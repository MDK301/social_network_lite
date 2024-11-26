import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_network_lite/featured/auth/presentation/pages/auth_page.dart';
import 'package:social_network_lite/featured/auth/presentation/pages/login_page.dart';
import 'package:social_network_lite/featured/auth/presentation/pages/register_page.dart';
import 'package:social_network_lite/themes/dark_mode.dart';

import 'app.dart';
import 'config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp ( MyApp());
}

