import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mt_my_ledger/core/extensions/screen_utils.dart';
import 'package:mt_my_ledger/presentation/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:mt_my_ledger/bloc/auth/auth_bloc.dart';
import 'package:mt_my_ledger/gen/assets.gen.dart';
import 'package:mt_my_ledger/models/tab_icon_data.dart';
import 'package:mt_my_ledger/presentation/all_transactions_screen.dart';
import 'package:mt_my_ledger/presentation/bottom_bar_view.dart';
import 'package:mt_my_ledger/presentation/category_screen.dart';
import 'package:mt_my_ledger/presentation/home_screen.dart';
import 'package:mt_my_ledger/presentation/settings_screen.dart';
import 'package:mt_my_ledger/presentation/side_navigation_rail.dart';
import 'package:mt_my_ledger/presentation/welcome_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  AnimationController? animationController;
  Widget tabBody = Container(color: Colors.white);

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AllTransactionsScreen(),
    CategoryScreen(),
    SettingsScreen(),
  ];

  List<TabIconData> tabIconsList = [];

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _configureFirebaseMessaging();
    tabIconsList = [
      TabIconData(
        imagePath: Assets.icons.today,
        selectedImagePath: Assets.icons.todaySolid,
        isSelected: true,
        index: 0,
        animationController: null,
      ),
      TabIconData(
        imagePath: Assets.icons.acute,
        selectedImagePath: Assets.icons.acuteSolid,
        isSelected: false,
        index: 1,
        animationController: null,
      ),
      TabIconData(
        imagePath: Assets.icons.category,
        selectedImagePath: Assets.icons.categorySolid,
        isSelected: false,
        index: 2,
        animationController: null,
      ),
      TabIconData(
        imagePath: Assets.icons.settings,
        selectedImagePath: Assets.icons.settingsSolid,
        isSelected: false,
        index: 3,
        animationController: null,
      ),
    ];

    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    tabBody = _widgetOptions[0];
  }

  void _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _configureFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    final apns = await FirebaseMessaging.instance.getAPNSToken();
    if (apns != null) {
      final fcm = await FirebaseMessaging.instance.getToken();
      print('FCM token: $fcm');
    } else {
      print('No APNs token (likely Simulator). Use simctl push for testing.');
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      for (var tab in tabIconsList) {
        tab.isSelected = false;
      }
      tabIconsList[index].isSelected = true;
      tabBody = _widgetOptions[index];
    });
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              if (!context.isMobile) {
                return Row(
                  children: [
                    SideNavigationRail(
                      tabIconsList: tabIconsList,
                      onIndexChanged: _onItemTapped,
                      addClick: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const AddTransactionScreen(),
                        );
                      },
                    ),
                    Expanded(child: tabBody),
                  ],
                );
              }
              return Stack(
                children: <Widget>[
                  tabBody,
                  Column(
                    children: <Widget>[
                      const Expanded(child: SizedBox()),
                      BottomBarView(
                        tabIconsList: tabIconsList,
                        addClick: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => const AddTransactionScreen(),
                          );
                        },
                        changeIndex: _onItemTapped,
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
