import 'dart:convert';
import 'package:admin/pages/components/custom_form.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/BaseAPI.dart';
import '../utils/persistence/secure_storage.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthAPI _authAPI = AuthAPI();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isObscure = true;

  void pushError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  Future<void> verifyLogin() async {
    if (!_formKey.currentState!.validate()) return;

    var email = emailController.text;
    var password = passwordController.text;

    try {
      var req = await _authAPI.login(email, password);
      if (req.statusCode == 200) {
        var token = jsonDecode(req.body);
        await SecureStorage().write('token', token);
        if (!context.mounted) {
          return;
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isLoggedIn", true);
        if (!context.mounted) {
          return;
        }
        final GlobalBloc globalBloc =
            Provider.of<GlobalBloc>(context, listen: false);
        globalBloc.onUserLogin();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return SplashPage();
            },
          ),
        );
      } else {}
    } catch (e) {
      print(e);
    }
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
        // Wrap SingleChildScrollView with Center
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the form
            children: [
              CustomForm(
                forgotPassword: true,
                formKey: _formKey,
                orLoginWith: true,
                fields: [
                  {
                    'labelText': 'Email',
                    'keyboardType': TextInputType.emailAddress,
                    'textInputAction': TextInputAction.next,
                    'controller': emailController,
                  },
                  {
                    'labelText': 'Password',
                    'keyboardType': TextInputType.visiblePassword,
                    'textInputAction': TextInputAction.done,
                    'controller': passwordController,
                    'obscureText': isObscure,
                    'suffixIcon': Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                        icon: Icon(
                          isObscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  },
                ],
                title: 'Sign in',
                subtitle: 'Navigate expert networks with simplicity',
                buttonText: 'Login',
                buttonAction: verifyLogin,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/org-registration'),
                      child: const Text('Register New Organization'),
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
