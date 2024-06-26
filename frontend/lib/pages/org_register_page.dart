import 'package:admin/pages/components/custom_form.dart';
import 'package:admin/pages/login_page.dart';
import 'package:admin/pages/user_register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/persistence/screen_arguments.dart';

class OrgRegisterPage extends StatefulWidget {
  const OrgRegisterPage({super.key});
  static const routeName = '/org-registration';

  @override
  State<OrgRegisterPage> createState() => _OrgRegisterPageState();
}

class _OrgRegisterPageState extends State<OrgRegisterPage> {
  final storage = FlutterSecureStorage();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController orgNameController = TextEditingController();
  // FocusNode confirmFocusNode = FocusNode();

  bool isObscure = true;

  Future<void> handleRegistration() async {
    Navigator.pushNamed(context, UserRegisterPage.routeName,
        arguments: ScreenArguments(orgNameController.text));
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
                orLoginWith: false,
                forgotPassword: false,
                formKey: _formKey,
                fields: [
                  {
                    'labelText': 'Organization Name',
                    'keyboardType': TextInputType.name,
                    'textInputAction': TextInputAction.next,
                    'controller': orgNameController,
                  },
                ],
                title: 'Register Your Organization',
                buttonText: 'Register',
                buttonAction: handleRegistration,
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
