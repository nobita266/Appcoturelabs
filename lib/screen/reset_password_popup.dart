import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ResetPasswordPopup {
  static Future<void> show(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: ResetPasswordContent(emailController),
      ),
    );
  }
}

class ResetPasswordContent extends StatelessWidget {
  final TextEditingController emailController;

  ResetPasswordContent(this.emailController);

  String emailQuery = '''
    mutation RequestPasswordResetEmail(\$email: String!) {
      requestPasswordResetEmail(email: \$email)
    }
  ''';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Container(
            child: Center(
              child: Text(
                'Enter your Registered Email Id To Receive The Reset Password Link',
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                obscureText: false,
                controller: emailController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Email',
                  labelText: 'Enter your email address',
                  prefixIcon: Icon(Icons.mail, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  return null;
                },
              ),
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Mutation(
            options: MutationOptions(
              document: gql(emailQuery),
              onCompleted: (data) {
                if (data == null) {
                  return;
                }

                final isEmailAvailable = data["requestPasswordResetEmail"];
                if (isEmailAvailable == null) {
                  return;
                }

                final isEmail = data['requestPasswordResetEmail'];

                if (isEmail == true) {
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send reset link.'),
                    ),
                  );
                }
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString()),
                  ),
                );
              },
            ),
            builder: (runMutation, result) {
              return ElevatedButton(
                onPressed: () {
                  runMutation({
                    'email': emailController.text,
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 36.0),
                  backgroundColor: Color(0xFF4A5B6D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SEND RESET LINK',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 12.0),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
