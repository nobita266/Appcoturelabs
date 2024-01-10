import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:magento_flutter/custom_icons.dart';
import 'package:magento_flutter/screen/reset_password_popup.dart';
import 'package:magento_flutter/screen/signup.dart';
import 'package:provider/provider.dart';

import '../provider/accounts.dart';
import '../utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
        title: const Text("Sign In"),
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
                child: Center(
                  child: Text(
                    'Enter Your Email or Phone Number',
                    style: TextStyle(
                      color: Color(0xFF4A5B6D),
                      fontFamily: 'Poppins',
                      fontSize: 25,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w900,
                    ),
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
              SizedBox(height: 31),
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
              SizedBox(height: 31),
              Container(
                width: 366,
                height: 48,
                child: ToggleButtons(
                  children: [
                    Container(
                      width: 183,
                      height: 48,
                      child: Center(child: Text('Phone Number')),
                    ),
                    Container(
                      width: 178,
                      height: 48,
                      child: Center(child: Text('Email ')),
                    ),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < isSelected.length;
                          buttonIndex++) {
                        if (buttonIndex == index) {
                          isSelected[buttonIndex] = !isSelected[buttonIndex];
                        } else {
                          isSelected[buttonIndex] = false;
                        }
                      }
                    });
                  },
                  isSelected: isSelected,
                ),
              ),
              SizedBox(height: 16),
              if (isSelected[0]) ...[
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
                                  borderRadius: BorderRadius.circular(4.0),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'SIGN IN',
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
                            text: "Don't have an Account?Sign up ",
                            style: TextStyle(
                              color: Color(0xFFA5ADB6),
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ] else ...[
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
                              labelText: 'Enter your email ',
                              prefixIcon: Icon(Icons.mail, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                showSnackBar(
                                    context, 'Please enter your email');
                                return null;
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
                            obscureText: false,
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              labelText: 'Enter your password',
                              prefixIcon: Icon(Icons.lock, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                showSnackBar(
                                    context, 'Please enter your email');
                                return null;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                ResetPasswordPopup.show(context);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerRight,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF4A5B6D),
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Container(
                              width: 366,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 366,
                                    height: 48,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black)),
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
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
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
                                            if (_formKey.currentState!
                                                .validate()) {
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
                                                  'SIGN IN',
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
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const SignUpScreen()),
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
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2), // Adjust the duration as needed
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
