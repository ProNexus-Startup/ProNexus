import 'package:admin/pages/components/custom_form.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  ResetPasswordPage({required this.email});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _message = '';

  Future<void> _resetPassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _message = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/reset-password'),
        body: {
          'email': widget.email,
          'new_password': _passwordController.text,
        },
      );

      setState(() {
        _isLoading = false;
        _message = response.statusCode == 200
            ? 'Password reset successfully'
            : 'Failed to reset password';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: CustomForm(
        formKey: _formKey,
        fields: [
          {
            'labelText': 'New Password',
            'keyboardType': TextInputType.text,
            'textInputAction': TextInputAction.next,
            'controller': _passwordController,
            'obscureText': true,
          },
          {
            'labelText': 'Confirm Password',
            'keyboardType': TextInputType.text,
            'textInputAction': TextInputAction.done,
            'controller': _confirmPasswordController,
            'obscureText': true,
          },
        ],
        title: 'Reset Password for ${widget.email}',
        subtitle: null,
        buttonText: _isLoading ? 'Loading...' : 'Reset Password',
        buttonAction: _resetPassword,
        forgotPassword: false,
        orLoginWith: false,
      ),
    );
  }
}
