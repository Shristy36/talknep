import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:talknep/UI/splash_screen.dart';
import 'package:talknep/provider/language_provider.dart';
import 'package:talknep/service/agora_config.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/service/notification_service.dart';
import 'package:talknep/service/provider_service.dart';
import 'package:talknep/service/theme_service.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/shared_preference.dart';
import 'constant/global.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'provider/menu/theme/theme_provider.dart';

var logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase Messaging background handler BEFORE any other Firebase operations
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Image Cache
  PaintingBinding.instance.imageCache.maximumSize = 200;

  // Max 50MB in cache
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;

  final token = await getToken();
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  if (token != null) {
    Global.token = token;

    ApiService.setToken(token);
    await AgoraResponse().init();
    await AgoraResponse().fetchAgoraTokenIfNeeded();
  }

  await FirebaseMessaging.instance.requestPermission();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // await NotificationService.init();

  runApp(MultiProvider(providers: providers(localeProvider), child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Sizer.init(context);

    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    Global.isEnglish = localeProvider.locale!.languageCode == 'en';

    return GetMaterialApp(
      title: 'TalkNep',
      theme: lightTheme,
      home: SplashScreen(),
      darkTheme: darkTheme,
      locale: localeProvider.locale,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
