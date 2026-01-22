import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import 'signup_page.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08007A), // Deep Blue Background
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 1),
              ),
            );
          } else if (state is AuthSuccess) {
            // Navigate to Dashboard
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Login Success!"),
                duration: const Duration(seconds: 1),
              ),
            );
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state is AuthForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Password reset email sent!"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Blurred Color Effect
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  // color: Removed prominent color to rely on shadow/blur
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF0099).withValues(alpha: 0.5),
                      blurRadius: 200, // Increased blur
                      spreadRadius: 80,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText('Welcome back!',
                                speed: const Duration(milliseconds: 100)),
                          ],
                          isRepeatingAnimation: false,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  label: "Email ID",
                                  controller: emailController,
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  label: "Password",
                                  isPassword: true,
                                  controller: passwordController,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      _showForgotPasswordDialog(context);
                                    },
                                    child: const Text("Forgot Password?"),
                                  ),
                                ),
                                const SizedBox(
                                    height: 40), // Spacer replacement
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return CustomButton(
                                      text: "Log in",
                                      isLoading: state is AuthLoading,
                                      onPressed: () {
                                        context.read<AuthBloc>().add(
                                              LoginRequested(
                                                email: emailController.text,
                                                password:
                                                    passwordController.text,
                                              ),
                                            );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                const Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Text("or login with"),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _socialButton(
                                      "assets/images/google.png",
                                      onTap: () {
                                        context
                                            .read<AuthBloc>()
                                            .add(const GoogleSignInRequested());
                                      },
                                    ),
                                    const SizedBox(width: 20),
                                    _socialButton("assets/images/facebook.png"),
                                    const SizedBox(width: 20),
                                    _socialButton("assets/images/apple.png"),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("New here? "),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignUpPage()),
                                        );
                                      },
                                      child: const Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(String assetPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70, // Increased size
        height: 70, // Increased size
        decoration: const BoxDecoration(
          // color: Colors.grey.shade100, // Removed grey background
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8), // Reduced padding
        child: Image.asset(assetPath),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController forgotPasswordController =
        TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Forgot Password"),
          content: TextField(
            controller: forgotPasswordController,
            decoration:
                const InputDecoration(hintText: "Enter your email address"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (forgotPasswordController.text.isNotEmpty) {
                  context.read<AuthBloc>().add(ForgotPasswordRequested(
                      email: forgotPasswordController.text));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("Send Reset Email"),
            ),
          ],
        );
      },
    );
  }
}
