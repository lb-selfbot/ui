import 'dart:io';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lightningui/api.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/launching.dart';
import 'package:lightningui/pages/activity.dart';
import 'package:lightningui/pages/config.dart';
import 'package:lightningui/pages/console.dart';
import 'package:lightningui/pages/home.dart';
import 'package:lightningui/pages/login.dart';
import 'package:lightningui/paths.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/services/startup_service.dart';
import 'package:lightningui/services/system_tray_service.dart';
import 'package:lightningui/services/theme_service.dart';
import 'package:lightningui/widgets/left_nav.dart';
import 'package:lightningui/widgets/titlebar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:sentry_flutter/sentry_flutter.dart';

const sentryDSN =
    'https://3cbd94268f7241f3a7bf986ec98f1088@o4504927797379072.ingest.sentry.io/4504927807537152';

final getIt = GetIt.instance;

List<String> cmdArgs = [];

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  cmdArgs = args;

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDSN;
      options.tracesSampleRate = 1.0;
    },
    appRunner: run,
  );
}

Future<void> run() async {
  try {
    launchAtStartup.setup(
      appName: "LightningBot",
      appPath: Platform.resolvedExecutable,
      args: ["--auto"],
    );

    await Paths.init();

    getIt.registerSingleton(ConfigService());

    await checkVersion();

    await Launching.init();

    getIt.registerSingleton(SystemTrayService());

    getIt.registerSingleton(ThemeService());

    getIt.registerSingleton(StartupService());

    IPC.tryConnect();

    // Don't await this so it can run in the background
    API.getFeatures();

    final isAutoStartup = cmdArgs.contains("--auto");

    runApp(App());

    doWhenWindowReady(() {
      appWindow
        ..minSize = const Size(720, 540)
        ..size = const Size(900, 640)
        ..alignment = Alignment.center
        ..title = "LightningBot";

      if (isAutoStartup) {
        appWindow.hide();
        getIt<SystemTrayService>().show();
      } else {
        appWindow.show();
      }
    });
  } catch (e) {
    await FlutterPlatformAlert.showAlert(
      windowTitle: "LightningBot - Error",
      text: "An error occurred. "
          "\n\nError data:"
          "\n\n  Exception: $e",
      iconStyle: IconStyle.information,
    );

    rethrow;
  }
}

Future<void> checkVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();

  if (packageInfo.version.contains("dev")) {
    // Don't check for updates on dev builds
    return;
  }

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

  // Only auto update on Windows
  if (!Platform.isWindows) {
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
      "${Platform.operatingSystem}/${Paths.architecture}/ui.exe";

  final installerPath = path.join(Paths.mainFolder, "installer.exe");

  try {
    final dio = Dio();

    await dio.download(downloadUrl, installerPath);

    await FlutterPlatformAlert.showAlert(
      windowTitle: "LightningBot - New Version Available",
      text: "The installer will open when you close this dialog. "
          "Please follow the instructions to update to the new version.",
      iconStyle: IconStyle.information,
    );

    await Process.run(
      "powershell",
      [
        "-Command",
        "Start-Process",
        "-FilePath",
        installerPath,
        "-Verb",
        "RunAs",
      ],
    );

    exit(0);
  } catch (e) {
    await FlutterPlatformAlert.showAlert(
      windowTitle: "LightningBot - New Version Available",
      text: "The download has failed. Please try again later "
          "or download the new version manually."
          "\n\nError data: $e",
      iconStyle: IconStyle.error,
    );

    exit(1);
  }
}

final currentRouteProvider = StateProvider<String>((ref) => '/');

final configProvider = ChangeNotifierProvider<ConfigService>((ref) {
  return getIt<ConfigService>();
});

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
  {
    'title': 'Activity',
    'icon': Icons.contacts,
    'route': '/activity',
  },
];

class DesktopScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class App extends StatelessWidget with GetItMixin {
  App({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final themeData = watchOnly((ThemeService t) => t.getTheme());

    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: DesktopScrollBehavior(),
        theme: themeData,
        home: AppBody(navigatorKey: navigatorKey),
      ),
    );
  }
}

class AppNavigator extends ConsumerWidget {
  const AppNavigator({super.key, required this.navigatorKey});

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
              case '/activity':
                return const ActivityPage();
              default:
                return Container();
            }
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
                opacity:
                    CurveTween(curve: Curves.easeInOutExpo).animate(animation),
                child: child);
          },
        );
      },
      initialRoute: '/',
    );
  }
}

class AppBody extends ConsumerStatefulWidget {
  const AppBody({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends ConsumerState<AppBody> {
  bool shouldLogin = true;
  bool passedFirstLogin = false;
  bool tryingToAuth = false;
  APIResult? authResult;

  void onLogin() {
    final username =
        getIt<ConfigService>().config["Account"]?["LightningBot"]?["Username"];

    Sentry.configureScope((scope) {
      scope.setUser(
        SentryUser(username: username ?? "no username"),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    shouldLogin = Launching.shouldLogin();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    if (!shouldLogin && !passedFirstLogin && !tryingToAuth) {
      tryingToAuth = true;
      final account = getIt<ConfigService>().config["Account"]["LightningBot"];
      API.auth(account["Username"], account["Password"]).then((result) {
        setState(() {
          authResult = result;
          tryingToAuth = false;
          passedFirstLogin = true;
        });
        onLogin();
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
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: ListView(
            children: [
              const WindowTitleBar(fullWidth: true),
              LoginPage(
                onLogin: () {
                  shouldLogin = false;
                  widget.navigatorKey.currentState?.popAndPushNamed('/');
                  ref.read(currentRouteProvider.notifier).state = '/';
                  setState(() {});
                  onLogin();
                },
                tryingToAuth: tryingToAuth && !shouldLogin,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LeftNav(navigatorKey: widget.navigatorKey),
          SizedBox(
            width: size.width - 150,
            height: size.height,
            child: Column(
              children: [
                const WindowTitleBar(),
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
