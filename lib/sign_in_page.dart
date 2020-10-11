import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:sooq1alzour/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:sooq1alzour/apple_sign_in_available.dart';

class SignInPage extends StatelessWidget {
  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithApple();
      print('uid: ${user.uid}');
    } catch (e) {
      // TODO: Show alert here
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appleSignInAvailable =
        Provider.of<AppleSignInAvailable>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (appleSignInAvailable.isAvailable)
              AppleSignInButton(
                style: ButtonStyle.black,
                type: ButtonType.signIn,
                onPressed: () => _signInWithApple(context),
              ),
          ],
        ),
      ),
    );
  }
}
