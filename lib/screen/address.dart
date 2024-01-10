import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:magento_flutter/screen/address_book.dart';

import 'package:magento_flutter/utils.dart';

class CustomerAddressRegionInput {
  final String region;
  final int region_id;

  CustomerAddressRegionInput({
    required this.region,
    required this.region_id,
  });

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'region_id': region_id,
    };
  }
}

enum CountryCodeEnum {
  US,
  AL,
  AR,
}

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final streetController = TextEditingController();
  final zipcodeController = TextEditingController();

  static const String countryQuery = '''
    query Countries {
    countries {
        available_regions {
            id
            name
        }
        two_letter_abbreviation
    }
}
  ''';

  static const String mutation1 = '''
  mutation CreateCustomerAddress(
    \$firstname: String!,
    \$lastname: String!,
    \$street: [String]!,
    \$postcode: String!,
    \$city: String!,
    \$region: CustomerAddressRegionInput!,
    \$telephone: String!,
    \$country_code: CountryCodeEnum!
  ) {
    createCustomerAddress(
      input: {
        firstname: \$firstname
        lastname: \$lastname
        street: \$street
        postcode: \$postcode
        city: \$city
        region: \$region
        telephone: \$telephone
        country_code: \$country_code
      }
    ) {
      id
      firstname
      lastname
      street
      postcode
      city
      region {
        region
        
      }
      telephone
      country_id
    }
  }
''';

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    streetController.dispose();
    zipcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Addresses'),
      ),
      body: Query(
        options: QueryOptions(document: gql(countryQuery)),
        builder: (QueryResult countryResult,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (countryResult.hasException) {
            return Text(countryResult.exception.toString());
          }

          if (countryResult.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          int getRegionId(String stateName, dynamic CountryResult) {
            if (CountryResult != null &&
                CountryResult.data['countries'] != null) {
              for (var country in CountryResult.data['countries']) {
                if (country['available_regions'] != null) {
                  for (var region in country['available_regions']) {
                    if (region['name'] == stateName) {
                      return region['id'];
                    }
                  }
                }
              }
            }
            return -1;
          }

          bool isregionAvailabe(dynamic countryResult) {
            if (countryResult.data?['countries']['available_regions'] != null)
              return true;
            else
              return false;
          }

          return Mutation(
            options: MutationOptions(
              document: gql(mutation1),
              onCompleted: (data) {},
              onError: (error) {
                print(error);
              },
            ),
            builder: (runMutation, result) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: 366,
                          height: 48,
                          child: TextFormField(
                            obscureText: false,
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.black),
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
                          width: 366,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                color: Color(0xFFEEF2F5), width: 1.0),
                          ),
                          child: IntlPhoneField(
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                            ),
                            initialCountryCode: 'IN',
                            controller: phoneController,
                            onChanged: (phone) {},
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: 366,
                          height: 48,
                          child: TextFormField(
                            obscureText: false,
                            controller: streetController,
                            decoration: InputDecoration(
                              hintText: 'Street',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter Street Address';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: 366,
                          height: 48,
                          child: TextFormField(
                            obscureText: false,
                            controller: zipcodeController,
                            decoration: InputDecoration(
                              hintText: 'Zipcode',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter Zipcode';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: CSCPicker(
                            flagState: CountryFlag.DISABLE,
                            layout: Layout.vertical,
                            onCountryChanged: (country) {
                              setState(() {
                                countryController.text = country ?? '';
                              });
                            },
                            onStateChanged: (state) {
                              setState(() {
                                stateController.text = state ?? '';
                              });
                            },
                            onCityChanged: (city) {
                              setState(() {
                                cityController.text = city ?? '';
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4A5B6D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  String shortname =
                                      getShortName(countryController.text);

                                  int r_id = getRegionId(
                                      stateController.text, countryResult);
                                  List<String> nameParts =
                                      nameController.text.split(' ');
                                  String firstName = nameParts[0];
                                  dynamic lastName = "";
                                  if (nameParts.length > 1)
                                    lastName = nameParts[1];
                                  print(lastName);

                                  Map<String, dynamic> mutationVariables = {
                                    "firstname": firstName,
                                    "lastname":
                                        lastName == "" ? firstName : lastName,
                                    "street": streetController.text,
                                    "postcode": zipcodeController.text,
                                    "telephone": phoneController.text,
                                    "city": cityController.text,
                                    "country_code": shortname,
                                    "region": CustomerAddressRegionInput(
                                      region: stateController.text,
                                      region_id: r_id == -1 ? 0 : r_id,
                                    ).toJson(),
                                  };

                                  runMutation(mutationVariables);

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddressBook(),
                                    ),
                                  );
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
                                      'Submit',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
