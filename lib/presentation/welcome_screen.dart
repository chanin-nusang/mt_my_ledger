import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mt_my_ledger/bloc/auth/auth_bloc.dart';
import 'package:mt_my_ledger/presentation/main_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else if (state.status == AuthStatus.unauthenticated) {
          String? errorMessage;
          try {
            // Attempt to read common error/message fields dynamically to avoid compile-time dependency
            errorMessage =
                (state as dynamic).error ?? (state as dynamic).message;
          } catch (_) {
            errorMessage = null;
          }
          if (errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/myledger_rounded_512.png',
                height: 100.0,
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to My Ledger',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthGoogleSignInRequested());
                },
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  height: 24.0,
                ),
                label: const Text('Sign in with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
