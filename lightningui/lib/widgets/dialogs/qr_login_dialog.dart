import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/launching.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/widgets/snackbar.dart';

import 'package:lottie/lottie.dart';

enum QRLoginStatus {
  loading,
  ready,
  success,
}

class QRLoginLoading extends StatelessWidget {
  const QRLoginLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Loading QR code..."),
        const SizedBox(height: 10),

        // A 10 second loading animation.
        // Loading the QR code seems to take 9-10 seconds.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 10),
          builder: (context, value, child) => LinearProgressIndicator(
            value: value,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class QRLoginReady extends StatelessWidget {
  const QRLoginReady({Key? key, required this.qrImage}) : super(key: key);

  final Uint8List qrImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Scan the QR code with your phone to log in."),
        const SizedBox(height: 10),
        Image.memory(
          qrImage,
          width: 300,
          height: 300,
        ),
      ],
    );
  }
}

class QRLoginSuccess extends StatefulWidget {
  const QRLoginSuccess({Key? key, required this.token}) : super(key: key);

  final String token;

  @override
  State<QRLoginSuccess> createState() => _QRLoginSuccessState();
}

class _QRLoginSuccessState extends State<QRLoginSuccess>
    with TickerProviderStateMixin {
  late final String censoredToken;
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    final splitToken = widget.token.split(".");
    censoredToken =
        "${splitToken[0]}.${splitToken[1]}.${"*" * splitToken[2].length}";

    controller = AnimationController(vsync: this);

    // Listen for the animation to finish
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Run onAnimationFinished after 1 second
        Future.delayed(const Duration(seconds: 1), onAnimationFinished);
      }
    });

    saveToken();
  }

  void onAnimationFinished() {
    if (mounted) Navigator.of(context).pop();
  }

  void saveToken() {
    final configService = getIt<ConfigService>();

    final config = configService.config;
    config["Account"]["Discord"]["Token"] = widget.token;
    configService.config = config;

    // Call the config change listeners
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      IPC.callListeners(IPC.onConfigChangeListeners);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // const Text("Scan the QR code with your phone to log in."),
        // const SizedBox(height: 10),
        Lottie.asset(
          "assets/animations/success.json",
          controller: controller,
          onLoaded: (composition) {
            controller
              ..duration = composition.duration
              ..forward();
          },
          width: 300,
          height: 300,
        ),
        Text(
          censoredToken,
          style: GoogleFonts.robotoMono(),
        ),
      ],
    );
  }
}

class QRLoginDialog extends StatefulWidget {
  const QRLoginDialog({Key? key}) : super(key: key);

  @override
  State<QRLoginDialog> createState() => _QRLoginDialogState();
}

class _QRLoginDialogState extends State<QRLoginDialog> {
  Process? process;
  Uint8List? qrImage;
  String? token;

  QRLoginStatus status = QRLoginStatus.loading;

  @override
  void initState() {
    super.initState();

    startProcess();
  }

  void onProcessData(List<int> data) {
    if (!mounted) return;

    const pngMagicBytes = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];

    if (listEquals(data.take(8).toList(), pngMagicBytes)) {
      // Data is a PNG, so we can assume it's the QR code
      setState(() {
        qrImage = Uint8List.fromList(data);
        status = QRLoginStatus.ready;
      });

      return;
    }

    final dataString = String.fromCharCodes(data);

    if (dataString.startsWith("ERR:")) {
      // Data is an error
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(
        message:
            "An error occurred while generating the QR code: ${dataString.substring(4)}",
        theme: Theme.of(context),
        size: MediaQuery.of(context).size,
      ));

      startProcess();

      return;
    }

    // Data is the token
    setState(() {
      token = dataString;
      status = QRLoginStatus.success;
    });
  }

  Future<void> startProcess() async {
    if (!mounted) return;

    setState(() => status = QRLoginStatus.loading);

    if (process != null) {
      process!.kill(ProcessSignal.sigkill);
    }

    final (error, qrProcess) = await Launching.launch(
      force: true,
      detached: false,
      args: ["-qrlogin"],
    );

    if (error != "" || qrProcess == null) {
      // Only show the error if the dialog is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(
          message: "An error occurred while generating the QR code: $error",
          theme: Theme.of(context),
          size: MediaQuery.of(context).size,
        ));

        startProcess();
      }

      return;
    }

    qrProcess.stdout.listen(onProcessData);

    if (mounted) setState(() => process = qrProcess);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (status) {
      case QRLoginStatus.loading:
        child = const QRLoginLoading();
        break;
      case QRLoginStatus.ready:
        child = QRLoginReady(qrImage: qrImage!);
        break;
      case QRLoginStatus.success:
        child = QRLoginSuccess(token: token!);
        break;
    }

    return AlertDialog(
      title: const Text("QR Login"),
      content: SizedBox(
        width: 400,
        child: child,
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: [
        TextButton(
          onPressed: startProcess,
          child: const Text("Refresh QR code"),
        ),
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }
}
