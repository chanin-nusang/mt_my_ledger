import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mt_my_ledger/bloc/category_bloc.dart';
import 'package:mt_my_ledger/bloc/category_event.dart';
import 'package:mt_my_ledger/bloc/theme_bloc.dart';
import 'package:mt_my_ledger/bloc/transaction_bloc.dart';
import 'package:mt_my_ledger/bloc/transaction_event.dart';
import 'package:mt_my_ledger/firebase_options.dart';
import 'package:mt_my_ledger/models/category.dart';
import 'package:mt_my_ledger/models/transaction.dart';
import 'package:mt_my_ledger/presentation/main_screen.dart';
import 'package:mt_my_ledger/presentation/themes.dart';
import 'package:mt_my_ledger/presentation/welcome_screen.dart';
import 'package:mt_my_ledger/repositories/category_repository.dart';
import 'package:mt_my_ledger/repositories/transaction_repository.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mt_my_ledger/repositories/auth_repository.dart';
import 'package:mt_my_ledger/bloc/auth/auth_bloc.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  await initializeDateFormatting();
  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
  } else {
    await Hive.initFlutter();
  }
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  final transactionBox = await Hive.openBox<Transaction>('transactions');
  final categoryBox = await Hive.openBox<Category>('categories');
  final authRepository = AuthRepository();
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);

  runApp(
    MyApp(
      transactionBox: transactionBox,
      categoryBox: categoryBox,
      authRepository: authRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Box<Transaction> transactionBox;
  final Box<Category> categoryBox;
  final AuthRepository authRepository;

  const MyApp({
    super.key,
    required this.transactionBox,
    required this.categoryBox,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(
          create: (context) =>
              TransactionBloc(TransactionRepository(transactionBox))
                ..add(LoadTransactions()),
        ),
        BlocProvider(
          create: (context) =>
              CategoryBloc(CategoryRepository(categoryBox))
                ..add(LoadCategories()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'My Ledger',
                locale: const Locale('th', 'TH'),
                supportedLocales: const [
                  Locale('th', 'TH'),
                  Locale('en', 'US'),
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeState.themeMode,
                home: authState.status == AuthStatus.authenticated
                    ? const MainScreen()
                    : const WelcomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
