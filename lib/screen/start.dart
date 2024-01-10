import 'package:flutter/material.dart';
import 'package:magento_flutter/custom_icons.dart';
import 'package:magento_flutter/provider/accounts.dart';
import 'package:magento_flutter/screen/categories.dart';
import 'package:magento_flutter/screen/guest_wishlist_popup.dart';
import 'package:magento_flutter/screen/wishlist.dart';
import 'package:magento_flutter/tabs/home_new.dart';
import 'package:magento_flutter/tabs/newin.dart';
import 'package:provider/provider.dart';

import '../provider/cart.dart';
import '../tabs/accounts.dart';

import '../tabs/home.dart';
import '../utils.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StateScreenState();
}

class _StateScreenState extends State<StartScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeTabsNew(),
    CategoriesScreen(),
    NewInTabs(),
    WishlistScreen(),
    AccountsTabs(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.id.isEmpty) {
      getCart(context).then((value) {
        if (value.isNotEmpty) {
          context.read<CartProvider>().setId(value);
        }
      });
    }
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CustomIcons.custom_home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(CustomIcons.widget_6),
              label: 'Catagories',
            ),
            BottomNavigationBarItem(
              icon: Icon(CustomIcons.frame_1000005328),
              label: 'New In',
            ),
            BottomNavigationBarItem(
              icon: Icon(IconData(0xe25c, fontFamily: 'MaterialIcons')),
              label: "Wishlist",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (value) {
            if (value == 3) {
              final isLoggedOn = isLoggedIn(context.read<AccountsProvider>());

              if (isLoggedOn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WishlistScreen()),
                );
              } else {
                GuestWishlistPopup.show(context);
              }
            } else {
              setState(() {
                _selectedIndex = value;
              });
            }
          },
        ),
      ),
    );
  }

  bool isLoggedIn(AccountsProvider accountsProvider) {
    return accountsProvider.isCustomer;
  }
}
