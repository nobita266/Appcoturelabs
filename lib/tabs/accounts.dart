import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:magento_flutter/screen/address_book.dart';
import 'package:magento_flutter/screen/signup.dart';
import 'package:provider/provider.dart';

import '../provider/accounts.dart';

import '../screen/myorder.dart';
import '../screen/signin.dart';
import '../screen/wishlist.dart';
import '../utils.dart';

class AccountsTabs extends StatelessWidget {
  const AccountsTabs({super.key});

  static const String customerQuery = """
  {
    customer {
      firstname
      lastname
    }
  }
  """;

  static const String revokeToken = """
  mutation {
    revokeCustomerToken {
      result
    }
  }
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Accounts"),
      ),
      body: accountsBody(context),
    );
  }

  Widget accountsBody(BuildContext context) {
    final isLoggedOn =
        context.select<AccountsProvider, bool>((value) => value.isCustomer);
    if (isLoggedOn) {
      return _customer(context);
    }
    return _guest(context);
  }

  Widget _guest(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            'Sign In for',
            style: TextStyle(
              color: Color(0xFFA5ADB6),
              fontFamily: 'Poppins',
              fontSize: 16,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Personalized your shopping',
            style: TextStyle(
              color: Color(0xFF4A5B6D),
              fontFamily: 'Poppins',
              fontSize: 20,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w600,
              height: 1.7,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 179,
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(vertical: 12, horizontal: 36),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xFF4A5B6D),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()),
                  ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 179,
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(vertical: 12, horizontal: 36),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xFF4A5B6D),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()),
                  ),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 24,
          ),
          Card(
            child: ListTile(
              title: const Text('Orders'),
              subtitle: const Text('Check your order status'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyOrderScreen()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Shipping Info'),
              subtitle: const Text(''),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 2.6,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/profile_cover.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _customer(BuildContext context) {
    return Query(
      options: QueryOptions(document: gql(customerQuery)),
      builder: (result, {fetchMore, refetch}) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        dynamic customer = result.data?['customer'];
        var screenSize = MediaQuery.of(context).size;
        return SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  _buildCoverImage(screenSize),
                  Column(
                    children: [
                      SizedBox(height: screenSize.height / 6.4),
                      _buildProfileImage(),
                      Text(
                        '${customer['firstname']} ${customer['lastname']}',
                      ),
                    ],
                  )
                ],
              ),
              Card(
                child: ListTile(
                  title: const Text('Orders'),
                  subtitle: const Text('Check your order status'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyOrderScreen()),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Address'),
                  subtitle: const Text('Save address for hassle-free checkout'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddressBook()),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Wishlist'),
                  subtitle: const Text('Check your wishlists'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WishlistScreen()),
                  ),
                ),
              ),
              Mutation(
                options: MutationOptions(
                  document: gql(revokeToken),
                  onCompleted: (data) {
                    final result = data?['revokeCustomerToken']?['result'];
                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Log out Succeeded!')),
                      );
                      Provider.of<AccountsProvider>(context, listen: false)
                          .signOff();
                      getCart(context);
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
                    child: const Text('Logout'),
                    onPressed: () {
                      runMutation({});
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
        ),
      ),
    );
  }
}
