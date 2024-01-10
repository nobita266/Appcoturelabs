import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:magento_flutter/screen/address.dart';

class AddressBook extends StatefulWidget {
  const AddressBook({Key? key}) : super(key: key);

  @override
  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  static String getAddressesQuery() {
    return """
      {
        customer {
          addresses {
            firstname
            lastname
            street
            city
            region {
              region
            }
            telephone
            id
          }
        }
      }
    """;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Address Book'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Query(
              options: QueryOptions(document: gql(getAddressesQuery())),
              builder: (result, {fetchMore, refetch}) {
                if (result.hasException) {
                  return Text(result.exception.toString());
                }

                if (result.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List addresses = result.data?['customer']['addresses'];
                print(addresses[0]['id']);

                if (addresses == null) {
                  return Text('No addresses found.');
                }

                return ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    var address = addresses[index];

                    var firstname = address['firstname'] ?? '';
                    var lastname = address['lastname'] ?? '';
                    var street1 = address['street'] != null
                        ? address['street'][0] ?? ''
                        : '';
                    var city = address['city'] ?? '';
                    var region = address['region'] != null
                        ? address['region']['region'] ?? ''
                        : '';
                    var telephone = address['telephone'] ?? '';

                    return Card(
                      shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Title(
                                  color: Colors.black,
                                  child: Text(
                                    'Home',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  )),
                              Row(
                                children: [
                                  Icon(Icons.delete),
                                  Icon(Icons.edit)
                                ],
                              ),
                            ],
                          ),
                          Text('$firstname $lastname'),
                          Text('$street1'),
                          Text('$city'),
                          Text('$region'),
                          Text('$telephone'),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16),
          TextButton(
              onPressed: () => {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressScreen(),
                      ),
                    )
                  },
              child: Text('Add New Address+'))
        ],
      ),
    );
  }
}
