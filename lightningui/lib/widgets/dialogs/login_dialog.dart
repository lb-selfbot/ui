import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/launching.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/widgets/snackbar.dart';

enum LoginStatus {
  choice,
  loginBrowser,
  loginSaved,
}

class UserData {
  UserData({
    required this.token,
    required this.username,
    required this.id,
    required this.avatar,
  });

  final String token;
  final String username;
  final String id;
  final String avatar;
}

class UserWidget extends StatelessWidget {
  UserWidget({Key? key, required this.userData}) : super(key: key);

  final UserData userData;

  final usernameStyle = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  final idStyle = GoogleFonts.roboto(
    fontSize: 15,
    fontWeight: FontWeight.w300,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(userData.avatar),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(userData.username, style: usernameStyle),
            Text(userData.id, style: idStyle),
          ],
        ),
      ],
    );
  }
}

class LoginBrowser extends StatefulWidget {
  const LoginBrowser({Key? key, required this.setToken}) : super(key: key);

  final void Function(String) setToken;

  @override
  State<LoginBrowser> createState() => _LoginBrowserState();
}

class _LoginBrowserState extends State<LoginBrowser> {
  Process? process;
  UserData? userData;

  @override
  void initState() {
    super.initState();

    startProcess();
  }

  void onProcessData(List<int> rawData) {
    if (!mounted) return;

    final data = jsonDecode(String.fromCharCodes(rawData));

    if (data["error"] != null) {
      // Data is an error
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(
        message: "An error occurred while logging in: ${data["error"]}",
        theme: Theme.of(context),
        size: MediaQuery.of(context).size,
      ));

      return;
    }

    widget.setToken(data["token"] as String);

    setState(
      () => userData = UserData(
        token: data["token"] as String,
        username: data["username"] as String,
        id: data["id"] as String,
        avatar: data["avatar"] as String,
      ),
    );
  }

  Future<void> startProcess() async {
    if (!mounted) return;

    if (this.process != null) {
      this.process!.kill(ProcessSignal.sigkill);
    }

    final (error, process) = await Launching.launch(
      force: true,
      detached: false,
      args: ["-weblogin"],
    );

    if (error != "" || process == null) {
      if (mounted) {
        // Only show the error if the dialog is still mounted
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(
          message: "An error occurred while logging in: $error",
          theme: Theme.of(context),
          size: MediaQuery.of(context).size,
        ));
      }

      return;
    }

    process.stdout.listen(onProcessData);

    if (mounted) setState(() => this.process = process);
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text("Please login to Discord in the browser..."),
        ],
      );
    }

    return UserWidget(userData: userData!);
  }
}

class LoginSaved extends StatefulWidget {
  const LoginSaved({Key? key, required this.setToken}) : super(key: key);

  final void Function(String) setToken;

  @override
  State<LoginSaved> createState() => _LoginSavedState();
}

class _LoginSavedState extends State<LoginSaved> {
  Process? process;
  List<UserData>? userDatas;
  UserData? chosenUserData;

  final usernameStyle = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  final idStyle = GoogleFonts.roboto(
    fontSize: 15,
    fontWeight: FontWeight.w300,
  );

  @override
  void initState() {
    super.initState();

    startProcess();
  }

  void onProcessData(List<int> rawData) {
    if (!mounted) return;

    final Iterable data = jsonDecode(String.fromCharCodes(rawData));

    if (data.isEmpty) {
      // Data is an error
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(
        message: "An error occurred while logging in: No saved tokens found",
        theme: Theme.of(context),
        size: MediaQuery.of(context).size,
      ));

      return;
    }

    final userDatas = <UserData>[];

    for (final user in data) {
      userDatas.add(UserData(
        token: user["token"] as String,
        username: user["username"] as String,
        id: user["id"] as String,
        avatar: user["avatar"] as String,
      ));
    }

    setState(() => this.userDatas = userDatas);
  }

  Future<void> startProcess() async {
    if (!mounted) return;

    if (this.process != null) {
      this.process!.kill(ProcessSignal.sigkill);
    }

    final (error, process) = await Launching.launch(
      force: true,
      detached: false,
      args: ["-savedtokens"],
    );

    if (error != "" || process == null) {
      if (mounted) {
        // Only show the error if the dialog is still mounted
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(
          message: "An error occurred while logging in: $error",
          theme: Theme.of(context),
          size: MediaQuery.of(context).size,
        ));
      }

      return;
    }

    process.stdout.listen(onProcessData);

    if (mounted) setState(() => this.process = process);
  }

  @override
  Widget build(BuildContext context) {
    if (userDatas == null) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text("Loading saved accounts..."),
        ],
      );
    }

    if (userDatas!.isEmpty) {
      return const Text(
        "No saved accounts found! Please use a different login method.",
      );
    }

    if (chosenUserData != null) {
      return UserWidget(userData: chosenUserData!);
    }

    return SingleChildScrollView(
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 20,
        children: [
          for (final userData in userDatas!)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserWidget(userData: userData),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => setState(() {
                    chosenUserData = userData;
                    widget.setToken(userData.token);
                  }),
                  child: const Text("Login"),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class LoginChoice extends StatelessWidget {
  const LoginChoice({Key? key, required this.setStatus}) : super(key: key);

  final void Function(LoginStatus) setStatus;

  final buttonStyle = const ButtonStyle(
    fixedSize: MaterialStatePropertyAll(Size(300, 40)),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () => setStatus(LoginStatus.loginBrowser),
          style: buttonStyle,
          icon: const Icon(Icons.web),
          label: const Text("Login with a web browser"),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => setStatus(LoginStatus.loginSaved),
          style: buttonStyle,
          icon: const Icon(Icons.discord),
          label: const Text("Login with a saved account"),
        ),
      ],
    );
  }
}

class LoginDialog extends StatefulWidget {
  const LoginDialog({Key? key}) : super(key: key);

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  LoginStatus status = LoginStatus.choice;
  String token = "";

  @override
  void initState() {
    super.initState();
  }

  void setStatus(LoginStatus newStatus) {
    setState(() => status = newStatus);
  }

  void setToken(String token) {
    setState(() => this.token = token);

    final configService = getIt<ConfigService>();

    final config = configService.config;
    config["Account"]["Discord"]["Token"] = token;
    configService.config = config;

    // Call the config change listeners
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      IPC.callListeners(IPC.onConfigChangeListeners);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (status) {
      case LoginStatus.choice:
        child = LoginChoice(setStatus: setStatus);
        break;
      case LoginStatus.loginBrowser:
        child = LoginBrowser(setToken: setToken);
        break;
      case LoginStatus.loginSaved:
        child = LoginSaved(setToken: setToken);
        break;
    }

    return AlertDialog(
      title: const Text("Discord Login"),
      content: SizedBox(
        width: 400,
        child: child,
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: [
        if (status != LoginStatus.choice && token == "")
          TextButton(
            onPressed: () => setStatus(LoginStatus.choice),
            child: const Text("Go back"),
          ),
        if (token != "")
          TextButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: token)),
            child: const Text("Copy token"),
          ),
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }
}
