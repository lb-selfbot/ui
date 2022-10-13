import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/api.dart';
import 'package:lightningui/widgets/snackbar.dart';

class LoginContainer extends StatelessWidget {
  const LoginContainer({
    Key? key,
    required this.size,
    required this.color,
    required this.child,
  }) : super(key: key);

  final Size size;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        margin: EdgeInsets.only(top: size.height / 3 - 50),
        child: Card(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({
    Key? key,
    required this.onLogin,
    required this.tryingToAuth,
  }) : super(key: key);

  final void Function() onLogin;
  final bool tryingToAuth;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void onLoginButtonPressed(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(WarningSnackBar(
        message: "Username cannot be empty!",
        theme: Theme.of(context),
        size: MediaQuery.of(context).size,
      ));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(WarningSnackBar(
        message: "Password cannot be empty!",
        theme: Theme.of(context),
        size: MediaQuery.of(context).size,
      ));
      return;
    }

    API.auth(username, password).then((result) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(SuccessSnackBar(
          message: "Logged in successfully!",
          theme: Theme.of(context),
          size: MediaQuery.of(context).size,
        ));
        onLogin();
      } else {
        final message = result.json["message"] as String? ?? "Unknown error";

        final snackBar = ErrorSnackBar(
          message: message,
          theme: Theme.of(context),
          size: MediaQuery.of(context).size,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).primaryColor;

    return LoginContainer(
      size: size,
      color: primaryColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: tryingToAuth ? loadingWidgets() : loginWidgets(context),
      ),
    );
  }

  List<Widget> loadingWidgets() {
    return [
      CircularProgressIndicator(),
      SizedBox(height: 20),
      Text(
        "Logging in...",
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    ];
  }

  List<Widget> loginWidgets(BuildContext context) {
    return [
      Text(
        'Login',
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w300,
        ),
      ),
      const SizedBox(height: 20),
      TextField(
        decoration: const InputDecoration(
          labelText: 'Username',
        ),
        toolbarOptions: const ToolbarOptions(
          copy: true,
          cut: true,
          paste: true,
        ),
        controller: _usernameController,
      ),
      const SizedBox(height: 20),
      TextField(
        decoration: const InputDecoration(
          labelText: 'Password',
        ),
        toolbarOptions: const ToolbarOptions(
          copy: true,
          cut: true,
          paste: true,
        ),
        controller: _passwordController,
        obscureText: true,
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => onLoginButtonPressed(context),
        child: const Text('Login'),
      ),
    ];
  }
}
