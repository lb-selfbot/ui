import 'dart:io';
import 'package:flutter/material.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/api.dart';
import 'package:lightningui/config.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/launching.dart';
import 'package:lightningui/pages/config.dart';
import 'package:lightningui/pages/console.dart';
import 'package:lightningui/pages/home.dart';
import 'package:lightningui/pages/login.dart';

import 'widgets/titlebar.dart';
import 'widgets/leftnav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Launching.init();
  IPC.tryConnect();

  runApp(App());

  if (Platform.isWindows) {
    doWhenWindowReady(() {
      appWindow
        ..minSize = const Size(720, 540)
        ..size = const Size(900, 640)
        ..alignment = Alignment.center
        ..show();
    });
  }
}

final currentRouteProvider = StateProvider<String>((ref) => '/');

const views = [
  {
    'title': 'Home',
    'icon': Icons.home,
    'route': '/',
  },
  {
    'title': 'Console',
    'icon': Icons.code,
    'route': '/console',
  },
  {
    'title': 'Config',
    'icon': Icons.settings,
    'route': '/config',
  },
];

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          splashFactory: InkRipple.splashFactory,
          primaryColor: const Color(0xFFFFAACC),
          useMaterial3: true,
          cardTheme: const CardTheme(
            color: Color(0xFF1B2D48),
            elevation: 2,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          splashFactory: InkRipple.splashFactory,
          // colorScheme: const ColorScheme.dark(
          //   error: Color(0xFFb00020),
          // ),
          primaryColor: const Color(0xFF1B2D48),
          primaryColorDark: const Color(0xFF2c4975),
          primaryColorLight: const Color(0xFF2e73db),
          useMaterial3: true,
          cardTheme: const CardTheme(
            color: Color(0xFF1B2D48),
            elevation: 2,
          ),
          tabBarTheme: TabBarTheme(
            labelStyle: GoogleFonts.montserrat(),
            unselectedLabelStyle: GoogleFonts.montserrat(),
          ),
          textTheme: GoogleFonts.montserratTextTheme(
            ThemeData.dark().textTheme,
          ),
          indicatorColor: const Color(0xFF47A7FF),
        ),
        themeMode: ThemeMode.dark,
        home: AppBody(navigatorKey: navigatorKey),
      ),
    );
  }
}

class AppNavigator extends ConsumerWidget {
  const AppNavigator({Key? key, required this.navigatorKey}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) {
            final currentRoute = ref.read(currentRouteProvider);
            switch (currentRoute) {
              case '/':
                return const HomePage();
              case '/console':
                return const ConsolePage();
              case '/config':
                return const ConfigPage();
              default:
                return Container();
            }
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
      initialRoute: '/',
    );
  }
}

class AppBody extends ConsumerStatefulWidget {
  const AppBody({Key? key, required this.navigatorKey}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends ConsumerState<AppBody> {
  bool shouldLogin = true;
  bool passedFirstLogin = false;
  bool tryingToAuth = false;
  APIResult? authResult;

  @override
  void initState() {
    super.initState();
    shouldLogin = Launching.shouldLogin();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (!shouldLogin && !passedFirstLogin && !tryingToAuth) {
      tryingToAuth = true;
      final account = Config.config["Account"]["LightningBot"];
      API.auth(account["Username"], account["Password"]).then((result) {
        setState(() {
          authResult = result;
          tryingToAuth = false;
          passedFirstLogin = true;
        });
      });
    }

    if (authResult != null) {
      if (authResult!.success) {
        shouldLogin = false;
      } else {
        shouldLogin = true;
      }
      authResult = null;
    }

    if (shouldLogin || tryingToAuth) {
      return Scaffold(
        backgroundColor: const Color(0xEE222222),
        body: Center(
          child: ListView(
            children: [
              const WindowTitleBar(dark: true, fullWidth: true),
              LoginPage(
                onLogin: () {
                  shouldLogin = false;
                  widget.navigatorKey.currentState?.popAndPushNamed('/');
                  ref.read(currentRouteProvider.notifier).state = '/';
                  setState(() {});
                },
                tryingToAuth: tryingToAuth && !shouldLogin,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xEE222222),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LeftNav(navigatorKey: widget.navigatorKey),
          SizedBox(
            width: size.width - 150,
            height: size.height,
            child: Column(
              children: [
                const WindowTitleBar(dark: true),
                const SizedBox(height: 30),
                SizedBox(
                  width: size.width - 150,
                  height: size.height - 65,
                  child: AppNavigator(navigatorKey: widget.navigatorKey),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
