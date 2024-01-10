import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:logger/logger.dart';

const addMutation = r'''
mutation AddProductsToWishlist($wishlistId: String!, $sku: String!) {
    addProductsToWishlist(
        wishlistId: $wishlistId
        wishlistItems: { sku: $sku, quantity: 1 }
    ) {
        wishlist {
            items_count
        }
    }
}
''';

var logger = Logger();

Widget addProductToWishlistMutation(String wishlistId, String sku) {
  logger.d('Entered func.');
  logger.d('$wishlistId $sku');

  return Mutation(
    options: MutationOptions(
      document: gql(addMutation),
      onCompleted: (data) {
        logger.d('entered onCompleted');
        if (kDebugMode) {
          logger.d(data);
          logger.d("Mutated");
        }
      },
      onError: (error) {
        if (kDebugMode) {
          logger.d(error);
        }
      },
    ),
    builder: (runMutation, result) {
      logger.d('Entered builder');

      runMutation({
        'wishlistId': wishlistId,
        'sku': sku,
      });

      logger.d('builder ended');

      return Container();
    },
  );
}
