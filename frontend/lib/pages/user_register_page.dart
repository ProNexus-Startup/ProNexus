import 'dart:convert';

import 'package:admin/pages/splash_page.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/global_bloc.dart';
import '../utils/persistence/screen_arguments.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import '../utils/login_stuff/screen_arguments.dart';
import '../utils/persistence/secure_storage.dart';
import '../utils/formatting/app_text_form_field.dart';
import '../utils/extensions.dart';
import '../utils/formatting/app_constants.dart';
import '../utils/BaseAPI.dart';
//import 'home_page.dart';

class UserRegisterPage extends StatefulWidget {
  final String org;

  static const routeName = '/user-registration';

  const UserRegisterPage({Key? key, required this.org}) : super(key: key);

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  AuthAPI _authAPI = AuthAPI();
  final storage = FlutterSecureStorage();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  //TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  //TextEditingController phoneController = TextEditingController();

  FocusNode confirmFocusNode = FocusNode();

  bool isObscure = true;
  bool isConfirmPasswordObscure = true;

  Future<void> handleRegistration() async {
    // First, validate the form
    if (_formKey.currentState?.validate() ?? false) {
      // Show a loading indicator or a message that email is being checked
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checking email availability...')),
      );
      print(widget.org);
      // Use the text property to get the string value from the controllers
      var req = await _authAPI.signup(
          usernameController.text,
          //lastNameController.text,
          emailController.text,
          //phoneController.text,
          passwordController.text,
          widget.org);
      print(req.statusCode);
      if (req.statusCode == 201 || req.statusCode == 200) {
        // || req.statusCode == 409) {
        if (!context.mounted) {
          print("context not mounted");
          return;
        }
        try {
          var req = await _authAPI.login(
              emailController.text, passwordController.text);
          print(req.statusCode);
          if (req.statusCode == 201 || req.statusCode == 200) {
            var token = jsonDecode(req.body);
            await SecureStorage().write('token', token);
            if (!context.mounted) {
              return;
            }
            //BlocProvider.of<UserCubit>(context).login(user);
            await Provider.of<GlobalBloc>(context, listen: false)
                .onUserLogin(token);
            if (!context.mounted) {
              return;
            }
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("isLoggedIn", true);
            if (!context.mounted) {
              return;
            }
            Navigator.pushNamed(context, SplashPage.routeName,
                arguments: ScreenArguments(token, widget.org));
            const SnackBar(content: Text('Email succesfully registered.'));
          } else {
            const SnackBar(content: Text('Problem registering.'));
          }
        } catch (e) {
          print(e);
          const SnackBar(content: Text('Problem registering.'));
        }
      } else {
        if (!context.mounted) {
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email is already registered.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = context.mediaQuerySize;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Container(
              height: size.height * 0.24,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        'Create your account',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppTextFormField(
                    labelText: 'Username',
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Enter Name '
                          : value.length < 4
                              ? 'Invalid Name'
                              : null;
                    },
                    controller: usernameController,
                  ),
                  /*AppTextFormField(
                    labelText: 'Last Name',
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Enter Last Name '
                          : value.length < 4
                              ? 'Invalid Name'
                              : null;
                    },
                    controller: lastNameController,
                  ),*/
                  AppTextFormField(
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Enter Email Address'
                          : AppConstants.emailRegex.hasMatch(value)
                              ? null
                              : 'Invalid Email Address';
                    },
                    controller: emailController,
                  ),
                  /*AppTextFormField(
                    labelText: 'Phone as (xxx) xxx-xxxx',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Enter Phone Number'
                          : AppConstants.phoneRegex.hasMatch(value)
                              ? null
                              : 'Invalid Phone Number';
                    },
                    controller: phoneController,
                  ),*/
                  AppTextFormField(
                    labelText: 'Password',
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Enter Password'
                          : AppConstants.passwordRegex.hasMatch(value)
                              ? null
                              : 'Invalid Password';
                    },
                    controller: passwordController,
                    obscureText: isObscure,
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      FocusScope.of(context).requestFocus(confirmFocusNode);
                    },
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Focus(
                        /// If false,
                        ///
                        /// disable focus for all of this node's descendants
                        descendantsAreFocusable: false,

                        /// If false,
                        ///
                        /// make this widget's descendants un-traversable.
                        // descendantsAreTraversable: false,
                        child: IconButton(
                          onPressed: () => setState(() {
                            isObscure = !isObscure;
                          }),
                          icon: Icon(
                            isObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppTextFormField(
                    labelText: 'Confirm Password',
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    focusNode: confirmFocusNode,
                    onChanged: (value) {
                      _formKey.currentState?.validate();
                    },
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please, Re-Enter Password'
                          : AppConstants.passwordRegex.hasMatch(value)
                              ? passwordController.text ==
                                      confirmPasswordController.text
                                  ? null
                                  : 'Password not matched!'
                              : 'Invalid Password!';
                    },
                    controller: confirmPasswordController,
                    obscureText: isConfirmPasswordObscure,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Focus(
                        /// If false,
                        ///
                        /// disable focus for all of this node's descendants.
                        descendantsAreFocusable: false,

                        /// If false,
                        ///
                        /// make this widget's descendants un-traversable.
                        // descendantsAreTraversable: false,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordObscure =
                                  !isConfirmPasswordObscure;
                            });
                          },
                          icon: Icon(
                            isConfirmPasswordObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        handleRegistration();
                      }
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
