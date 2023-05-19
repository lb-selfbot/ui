import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/services/config_service.dart';

class StartupService {
  StartupService() {
    getIt<ConfigService>().addListener(setupStartup);

    setupStartup();
  }

  Future<void> setupStartup() async {
    final config = getIt<ConfigService>().config;

    final runOnStartup = config['UI']['RunOnStartup'];

    if (runOnStartup) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }
}
