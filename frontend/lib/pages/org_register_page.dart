import 'dart:convert';

import 'package:admin/pages/user_register_page.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/persistence/screen_arguments.dart';
import '../utils/models/app_text_form_field.dart';
import '../utils/extensions.dart';
import '../utils/BaseAPI.dart';
//import 'home_page.dart';

class OrgRegisterPage extends StatefulWidget {
  const OrgRegisterPage({super.key});
  static const routeName = '/org-registration';

  @override
  State<OrgRegisterPage> createState() => _OrgRegisterPageState();
}

class _OrgRegisterPageState extends State<OrgRegisterPage> {
  AuthAPI _authAPI = AuthAPI();
  final storage = FlutterSecureStorage();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController orgNameController = TextEditingController();
  // FocusNode confirmFocusNode = FocusNode();

  bool isObscure = true;

  Future<void> handleRegistration() async {
    // First, validate the form
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checking organization availability...')),
      );
      // Use the text property to get the string value from the controllers
      var req = await _authAPI.makeOrg(orgNameController.text);
      print(req.statusCode);
      if (req.statusCode == 201 || req.statusCode == 200) {
        // || req.statusCode == 409) {
        if (!context.mounted) {
          print("context not mounted");
          return;
        }
        var data = jsonDecode(req.body);
        print(data);
        String orgID = data['organizationID'];
        await SecureStorage().write('organizationID', orgID);
        Navigator.pushNamed(context, UserRegisterPage.routeName,
            arguments: ScreenArguments(orgID, "emptytoken"));
        const SnackBar(content: Text('Organization succesfully registered.'));
      } else {
        const SnackBar(content: Text('Problem registering.'));
      }

      @override
      Widget build(BuildContext context) {
        // TODO: implement build
        throw UnimplementedError();
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
                      Text(
                        'Register your organization',
                      ),
                      const SizedBox(
                        height: 6,
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
                    labelText: 'Organization Name',
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
                    controller: orgNameController,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'I have an account?',
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Login',
                    ),
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
