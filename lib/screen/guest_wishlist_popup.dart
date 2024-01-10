import 'package:flutter/material.dart';
import 'package:magento_flutter/screen/signin.dart';

class GuestWishlistPopup {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Wishlist',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A5B6D),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                          context); // Make sure to replace 'context' with your actual context variable
                    },
                    icon: Icon(Icons.cancel),
                  )
                ],
              ),
              SizedBox(height: 16),
              Column(children: [
                Text(
                  "Did you know, by signing in, You can sync your\n wishlist to any device?",
                  style: TextStyle(
                    color: Color(0xFFA5ADB6),
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    height: 1.71429,
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A5B6D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()),
                  ),
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
                ),
              ]),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
