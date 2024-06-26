import 'package:admin/pages/components/custom_form.dart';
import 'package:admin/pages/login_page.dart';
import 'package:admin/utils/BaseAPI.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  static const routeName = '/password-reset';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Align(
          alignment: Alignment.topLeft,
          child: Image.asset(
            'images/thin_logo.png',
            height: 100,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomForm(
                orLoginWith: false,
                forgotPassword: false,
                formKey: _formKey,
                fields: [
                  {
                    'labelText': 'Email',
                    'keyboardType': TextInputType.emailAddress,
                    'textInputAction': TextInputAction.next,
                    'controller': emailController,
                    'validator': (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  },
                ],
                title: 'Reset Password',
                buttonText: 'Reset',
                buttonAction: () async {
                  final AuthAPI _authAPI = AuthAPI();
                  bool reset =
                      await _authAPI.resetPassword(emailController.text);
                  if (reset) {
                    showMessage('Password reset email sent');
                  } else {
                    showMessage('Couldn\'t find email');
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Have an account?"),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, LoginPage.routeName),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
