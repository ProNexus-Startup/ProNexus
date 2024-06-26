import 'package:admin/pages/forgot_password_page.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:flutter/material.dart';

class CustomForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Map<String, dynamic>> fields;
  final String title;
  final String? subtitle;
  final String buttonText;
  final VoidCallback buttonAction;
  final bool forgotPassword;
  final bool orLoginWith;

  CustomForm({
    required this.formKey,
    required this.fields,
    required this.title,
    this.subtitle,
    required this.buttonText,
    required this.buttonAction,
    required this.forgotPassword,
    required this.orLoginWith,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Form(
                key: formKey,
                child: Container(
                  width: size.width * 0.3 < 300 ? 300 : size.width * 0.3,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: TextStyle(fontSize: 16),
                            ),
                        ],
                      ),
                      SizedBox(height: 30),
                      ...fields.map((field) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: AppTextFormField(
                              labelText: field['labelText'],
                              keyboardType: field['keyboardType'],
                              textInputAction: field['textInputAction'],
                              controller: field['controller'],
                              obscureText: field['obscureText'] ?? false,
                              suffixIcon: field['suffixIcon'] ?? null,
                            ),
                          )),
                      if (forgotPassword)
                        Align(
                          alignment: Alignment.topLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, ForgotPasswordPage.routeName);
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: buttonAction,
                          child: Text(buttonText),
                        ),
                      ),
                      if (orLoginWith) SizedBox(height: 30),
                      if (orLoginWith)
                        Row(
                          children: [
                            Expanded(
                              child: Divider(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text('Or login with'),
                            ),
                            Expanded(
                              child: Divider(),
                            ),
                          ],
                        ),
                      if (orLoginWith) SizedBox(height: 30),
                      if (orLoginWith)
                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              // Add your onPressed logic here
                              print('SSO Button Pressed');
                            },
                            child: Container(
                              width: 150,
                              height: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    12), // Add border radius here
                                border: Border.all(
                                  color: Colors
                                      .black, // Adjust the border color as needed
                                  width: 2, // Adjust the border width as needed
                                ),
                                color: offWhite,
                                image: DecorationImage(
                                  image: AssetImage('images/sso.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    required this.textInputAction,
    required this.labelText,
    required this.keyboardType,
    required this.controller,
    super.key,
    this.onChanged,
    this.validator,
    this.obscureText,
    this.suffixIcon,
    this.onEditingComplete,
    this.autofocus,
    this.focusNode,
  });

  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool? obscureText;
  final Widget? suffixIcon;
  final String labelText;
  final bool? autofocus;
  final FocusNode? focusNode;
  final void Function()? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        focusNode: focusNode,
        onChanged: onChanged,
        autofocus: autofocus ?? false,
        validator: validator,
        obscureText: obscureText ?? false,
        obscuringCharacter: '*',
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: (value) {
          FocusScope.of(context).unfocus();
        },
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
