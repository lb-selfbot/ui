import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lightningui/paths.dart';
import 'package:lightningui/systemtray.dart';
import 'package:lightningui/utils.dart';

import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
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

  await checkVersion();

  await Launching.init();
  IPC.tryConnect();

  await SystemTray.init();

  runApp(App());

  doWhenWindowReady(() {
    appWindow
      ..minSize = const Size(720, 540)
      ..size = const Size(900, 640)
      ..alignment = Alignment.center
      ..title = "LightningBot"
      ..show();
  });
}

Future<void> checkVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();

  final apiResponse = await API.checkVersion("ui", packageInfo.version);

  if (!apiResponse.success) {
    await FlutterPlatformAlert.showAlert(
      windowTitle: "LightningBot - Error",
      text: "An error occurred while checking for updates. "
          "Please check your internet connection and try again. "
          "Check the status on our Discord server if the problem persists."
          "\n\nError data:"
          "\n\n  Status code: ${apiResponse.response?.statusCode} ${apiResponse.response?.reasonPhrase}"
          "\n\n  Response: ${apiResponse.response?.body}"
          "\n\n  Exception: ${apiResponse.error}",
      iconStyle: IconStyle.information,
    );
    exit(0);
  }

  final isLatest = apiResponse.json["is_latest"];

  if (isLatest) {
    return;
  }

  // No auto update on Linux
  if (Platform.isLinux) {
    await FlutterPlatformAlert.showAlert(
      windowTitle: "LightningBot - New Version Available",
      text: "A new version of LightningBot is available. "
          "Please download the latest version from our website.",
      iconStyle: IconStyle.information,
    );
    exit(0);
  }

  await FlutterPlatformAlert.showAlert(
    windowTitle: "LightningBot - New Version Available",
    text: "This version of LightningBot is outdated. "
        "The new version will download when you close this dialog. "
        "Please wait for the download to complete, you will be notified when it is ready.",
    iconStyle: IconStyle.information,
  );

  String downloadUrl = "${API.baseUrl}/static/executables/"
      "${Platform.operatingSystem}/${Launching.architecture}/selfbot";

  if (Platform.isMacOS) {
    downloadUrl = "${API.baseUrl}/static/executables/macos/ui";
  }
  if (Platform.isWindows) {
    downloadUrl += ".exe";
  }

  final installerPath = path.join(Paths.mainFolder, "installer.exe");

  final success = await Utils.downloadFile(downloadUrl, installerPath);

  if (success) {
    await FlutterPlatformAlert.showAlert(
      windowTitle: "LightningBot - New Version Available",
      text: "The installer will open when you close this dialog. "
          "Please follow the instructions to update to the new version.",
      iconStyle: IconStyle.information,
    );

    Process.start(installerPath, [], mode: ProcessStartMode.detached);
  } else {
    await FlutterPlatformAlert.showAlert(
      windowTitle: "LightningBot - New Version Available",
      text: "The download has failed. Please try again later "
          "or download the new version manually.",
      iconStyle: IconStyle.error,
    );
  }

  exit(0);
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
