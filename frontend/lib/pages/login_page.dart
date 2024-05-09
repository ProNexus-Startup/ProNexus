import 'dart:convert';

import 'package:admin/utils/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_page.dart';

///import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/formatting/app_text_form_field.dart';
//import 'resources/vectors.dart';
//import '../utils/extensions.dart';
//import '../../utils/formatting/app_constants.dart';
import '../utils/BaseAPI.dart';
import '../utils/persistence/secure_storage.dart';
//import '../utils/login_stuff/screen_arguments.dart';

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
      print(req.statusCode);
      if (req.statusCode == 200) {
        var token = jsonDecode(req.body);
        await SecureStorage().write('token', token);
        if (!context.mounted) {
          return;
        }
        //BlocProvider.of<UserCubit>(context).login(user); add back when you need to update user info
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isLoggedIn", true);
        if (!context.mounted) {
          return;
        }
        final GlobalBloc globalBloc =
            Provider.of<GlobalBloc>(context, listen: false);
        globalBloc.onUserLogin(token);
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
    //final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign in to your\nAccount',
                    ),
                    SizedBox(
                      height: 6,
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextFormField(
                      labelText: 'Email',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) {
                        _formKey.currentState?.validate();
                      },
                      /*validator: (value) {
                        return value!.isEmpty
                            ? 'Please, Enter Username Address'
                            : AppConstants.emailRegex.hasMatch(value)
                                ? null
                                : 'Invalid Username Address';
                      },*/
                      controller: emailController,
                    ),
                    AppTextFormField(
                      labelText: 'Password',
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      /*onChanged: (value) {
                        _formKey.currentState?.validate();
                      },
                      validator: (value) {
                        return value!.isEmpty
                            ? 'Please, Enter Password'
                            : AppConstants.passwordRegex.hasMatch(value)
                                ? null
                                : 'Invalid Password';
                      },*/
                      controller: passwordController,
                      obscureText: isObscure,
                      suffixIcon: Padding(
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
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/password_reset');
                      },
                      child: const Text(
                        'Forgot Password?',
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    FilledButton(
                      onPressed:
                          verifyLogin, // Updated to call verifyLogin directly
                      child: const Text('Login'),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Text(
                            'Or login with',
                          ),
                        ),
                        Expanded(
                          child: Divider(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    /*Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: Theme.of(context).outlinedButtonTheme.style,
                            icon: SvgPicture.asset(
                              Vectors.googleIcon,
                              width: 14,
                            ),
                            label: const Text(
                              'Google',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: Theme.of(context).outlinedButtonTheme.style,
                            icon: SvgPicture.asset(
                              Vectors.facebookIcon,
                              width: 14,
                            ),
                            label: const Text(
                              'Facebook',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),*/
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                    ),
                    TextButton(
                      onPressed: () =>
                          {Navigator.pushNamed(context, '/org-registration')},
                      child: const Text(
                        'Register New Organization',
                      ),
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
