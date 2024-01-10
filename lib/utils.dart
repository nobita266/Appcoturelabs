import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const Map<String, String> _currencies = {
  'USD': '\$',
  'EUR': '€',
  'AUD': 'A\$',
  'GBP': '£',
  'CAD': 'CA\$',
  'CNY': 'CN¥',
  'JPY': '¥',
  'SEK': 'SEK',
  'CHF': 'CHF',
  'INR': '₹',
  'KWD': 'د.ك',
  'RON': 'RON',
};

String currencyWithPrice(dynamic price) {
  final currency = _currencies[price['currency']];
  return '$currency${price['value'].toString()}';
}

int certainPlatformGridCount() {
  var gridViewCount = 4;
  if (Platform.isIOS || Platform.isAndroid || Platform.isFuchsia) {
    gridViewCount = 2;
  }
  return gridViewCount;
}

Future<String> getCart(BuildContext context) async {
  final client = GraphQLProvider.of(context).value;
  var result = await client.mutate(
    MutationOptions(document: gql('''
    mutation {
      createEmptyCart
    }
    ''')),
  );

  if (result.hasException) {
    if (kDebugMode) {
      print(result.exception.toString());
    }
    return "";
  }

  return result.data?['createEmptyCart'];
}

Map<String, String> countryCodes = {
  'Afghanistan': 'AF',
  'Albania': 'AL',
  'Algeria': 'DZ',
  'Andorra': 'AD',
  'Angola': 'AO',
  'Antarctica': 'AQ',
  'Argentina': 'AR',
  'Armenia': 'AM',
  'Australia': 'AU',
  'Austria': 'AT',
  'Azerbaijan': 'AZ',
  'Bahrain': 'BH',
  'Bangladesh': 'BD',
  'Belgium': 'BE',
  'Bhutan': 'BT',
  'Brazil': 'BR',
  'Bulgaria': 'BG',
  'Canada': 'CA',
  'China': 'CN',
  'Colombia': 'CO',
  'Croatia': 'HR',
  'Czech Republic': 'CZ',
  'Denmark': 'DK',
  'Egypt': 'EG',
  'Estonia': 'EE',
  'Finland': 'FI',
  'France': 'FR',
  'Germany': 'DE',
  'Greece': 'GR',
  'Hungary': 'HU',
  'India': 'IN',
  'Indonesia': 'ID',
  'Ireland': 'IE',
  'Italy': 'IT',
  'Japan': 'JP',
  'Kenya': 'KE',
  'South Korea': 'KR',
  'Malaysia': 'MY',
  'Mexico': 'MX',
  'Netherlands': 'NL',
  'New Zealand': 'NZ',
  'Nigeria': 'NG',
  'Norway': 'NO',
  'Pakistan': 'PK',
  'Peru': 'PE',
  'Poland': 'PL',
  'Portugal': 'PT',
  'Qatar': 'QA',
  'Romania': 'RO',
  'Russia': 'RU',
  'Saudi Arabia': 'SA',
  'Singapore': 'SG',
  'South Africa': 'ZA',
  'Spain': 'ES',
  'Sweden': 'SE',
  'Switzerland': 'CH',
  'Turkey': 'TR',
  'Ukraine': 'UA',
  'United Arab Emirates': 'AE',
  'United Kingdom': 'GB',
  'United States': 'US',
  'Vietnam': 'VN',
};

String getShortName(String countryName) {
  return countryCodes[countryName] ?? 'N/A';
}
