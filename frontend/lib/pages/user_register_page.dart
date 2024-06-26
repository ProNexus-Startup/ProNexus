import 'dart:convert';

import 'package:admin/pages/components/custom_form.dart';
import 'package:admin/pages/splash_page.dart';
import 'package:admin/utils/models/user.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/persistence/global_bloc.dart';
import '../utils/persistence/screen_arguments.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import '../utils/login_stuff/screen_arguments.dart';
import '../utils/persistence/secure_storage.dart';
import '../utils/BaseAPI.dart';
//import 'home_page.dart';

class UserRegisterPage extends StatefulWidget {
  final String token; // Here the token is the org

  static const routeName = '/user-registration';

  const UserRegisterPage({Key? key, required this.token}) : super(key: key);

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  AuthAPI _authAPI = AuthAPI();
  final storage = FlutterSecureStorage();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode confirmFocusNode = FocusNode();

  bool isObscure = true;
  bool isObscureConfirm = true;
  bool isConfirmPasswordObscure = true;

  Future<void> handleRegistration() async {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checking email availability...')),
      );

      print(widget.token);
      print('orga above');

      var orgResponse = await _authAPI.makeOrg(widget.token);
      if (orgResponse.statusCode == 201 || orgResponse.statusCode == 200) {
        if (!context.mounted) return;

        var data = jsonDecode(orgResponse.body);
        String orgID = data['organizationID'];

        final GlobalBloc globalBloc =
            Provider.of<GlobalBloc>(context, listen: false);

        User user = User(
          email: emailController.text,
          fullName: usernameController.text,
          password: passwordController.text,
          organizationId: orgID,
          admin: true,
          currentProject: globalBloc.benchProject,
          pastProjects: [
            Proj(projectId: globalBloc.benchProject, start: DateTime(1, 1)),
          ],
        );

        var signupResponse = await _authAPI.signup(user);
        if (signupResponse.statusCode == 201 ||
            signupResponse.statusCode == 200) {
          if (!context.mounted) return;

          var loginResponse = await _authAPI.login(
            emailController.text,
            passwordController.text,
          );

          if (loginResponse.statusCode == 201 ||
              loginResponse.statusCode == 200) {
            var token = jsonDecode(loginResponse.body);
            await SecureStorage().write('token', token);

            if (!context.mounted) return;

            await Provider.of<GlobalBloc>(context, listen: false).onUserLogin();

            if (!context.mounted) return;

            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("isLoggedIn", true);

            if (!context.mounted) return;

            Navigator.pushNamed(context, SplashPage.routeName,
                arguments: ScreenArguments(token));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email successfully registered.')),
            );
          } else {
            _showErrorSnackBar('Problem registering.');
          }
        } else {
          _showErrorSnackBar('Email is already registered.');
        }
      } else {
        _showErrorSnackBar('Organization is already registered.');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
        // Wrap SingleChildScrollView with Center
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the form
            children: [
              CustomForm(
                forgotPassword: false,
                formKey: _formKey,
                orLoginWith: false,
                fields: [
                  {
                    'labelText': 'Email',
                    'keyboardType': TextInputType.emailAddress,
                    'textInputAction': TextInputAction.next,
                    'controller': emailController,
                  },
                  {
                    'labelText': 'Full Name',
                    'keyboardType': TextInputType.name,
                    'textInputAction': TextInputAction.next,
                    'controller': usernameController,
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
                  {
                    'labelText': 'Confirm Password',
                    'keyboardType': TextInputType.visiblePassword,
                    'textInputAction': TextInputAction.done,
                    'controller': confirmPasswordController,
                    'obscureText': isObscureConfirm,
                    'suffixIcon': Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isObscureConfirm = !isObscureConfirm;
                          });
                        },
                        icon: Icon(
                          isObscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  },
                ],
                title: 'Create Your Account',
                buttonText: 'Register',
                buttonAction: handleRegistration,
              ),
              /*Padding(
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
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
