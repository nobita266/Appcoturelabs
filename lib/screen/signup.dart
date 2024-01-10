import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:magento_flutter/custom_icons.dart';
import 'package:magento_flutter/screen/signin.dart';
import 'package:provider/provider.dart';

import '../provider/accounts.dart';
import '../utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const String createToken = """
    mutation CreateCustomerToken(\$email: String!, \$pass: String!) {
      generateCustomerToken(
        email: \$email
        password: \$pass
      ) {
        token
      }
    }
  """;

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  List<bool> isSelected = [
    true,
    false,
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        reverse: true,
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                width: 366,
                height: 66,
                child: Text(
                  "Let's \nget personal",
                  style: TextStyle(
                    color: Color(0xFF4A5B6D),
                    fontFamily: 'Poppins',
                    fontSize: 25,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: 31),
              Container(
                width: 366,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Color(0xFFEEF2F5), width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: 175,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border:
                              Border.all(color: Color(0xFFEEF2F5), width: 1.0),
                          color: Color(0xFFFFFFFF),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CustomIcons.group,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'APPLE',
                              style: TextStyle(
                                color: Color(0xFF4A5B6D),
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: 175,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border:
                              Border.all(color: Color(0xFFEEF2F5), width: 1.0),
                          color: Color(0xFFFFFFFF),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CustomIcons.frame,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'GOOGLE',
                              style: TextStyle(
                                color: Color(0xFF4A5B6D),
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 32,
              ),
              Center(
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Color(0xFFA5ADB6),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                  width: 366,
                  height: 70,
                  child: IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    initialCountryCode: 'IN',
                    onChanged: (phone) {},
                  )),
              SizedBox(
                height: 16,
              ),
              Container(
                width: 366,
                height: 48,
                child: TextFormField(
                  obscureText: false,
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    labelText: 'Enter Name',
                    prefixIcon: Icon(Icons.person, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Your Name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 366,
                        height: 48,
                        child: TextFormField(
                          obscureText: false,
                          controller: emailController,
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
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: 366,
                        height: 48,
                        child: TextFormField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            labelText: 'Enter password',
                            prefixIcon: Icon(Icons.lock, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Container(
                        width: 366,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 366,
                              height: 48,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black)),
                              child: Mutation(
                                options: MutationOptions(
                                  document: gql(createToken),
                                  onCompleted: (data) {
                                    if (data == null) {
                                      return;
                                    }
                                    final generateToken =
                                        data['generateCustomerToken'];
                                    if (generateToken == null) {
                                      return;
                                    }
                                    final token = generateToken['token'];
                                    Provider.of<AccountsProvider>(context,
                                            listen: false)
                                        .signIn(token);
                                    getCart(context);
                                    Navigator.pop(context);
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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4A5B6D),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        runMutation({
                                          'email': emailController.text,
                                          'pass': passwordController.text,
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 36),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'SIGN UP',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an Account?",
                                  style: TextStyle(
                                    color: Color(
                                      0xFFA5ADB6,
                                    ),
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign In",
                                      style: TextStyle(
                                        color: Color(0xFF4A5B6D),
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignInScreen()),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
