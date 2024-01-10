import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:magento_flutter/screen/product.dart';
import 'package:magento_flutter/utils.dart';
import 'package:magento_flutter/wishlist_add_mutation.dart';

class CategoryScreen extends StatefulWidget {
  final String title;
  final String categoryId;
  final String wishlistId;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.categoryId,

    // WishlistID has been hard-coded for now.
    // It needs to be in the global state when user logs in
    // and removed from global state when user logs out.
    required this.wishlistId,
  });

  @override
  State createState() => _CategoryScreen();
}

class _CategoryScreen extends State<CategoryScreen> {
  static const query = r"""
  query GetProductByCategory($categoryId: String, $currentPage: Int) {
     products(
        filter: { category_uid: { eq: $categoryId } }
        pageSize: 10
        currentPage: $currentPage
    ) {
        items {
            name
            sku
            description {
                html
            }
            image {
                url
            }
            price_range {
                minimum_price {
                    final_price {
                        currency
                        value
                    }
                    discount {
                        percent_off
                    }
                    regular_price {
                        currency
                        value
                    }
                }
            }
            media_gallery {
                url
            }
        }
        total_count
    }
      
    wishlist {
      items {
        product {
          sku
        }
      }
    }
  }
  """;

  List? items;

  List? wishlistItems;

  List wishlistItemsSku = [];

  final _scrollController = ScrollController();

  int currentP = 1;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(),
        body: Column(
          children: [
            searchBar(),
            products(context),
          ],
        ));
  }

  Container sortFilterBar(int totalCount) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Showing ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xffA5ADB6),
                ),
              ),
              Text(
                '$totalCount products',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xff4A5B6D),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  children: [
                    Container(
                        margin: const EdgeInsets.only(right: 5),
                        child: SvgPicture.asset('assets/icons/Filter.svg')),
                    const Text(
                      'Sort',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                      margin: const EdgeInsets.only(right: 5),
                      child: SvgPicture.asset('assets/icons/Sort.svg')),
                  const Text(
                    'Filter',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Expanded products(BuildContext context) {
    return Expanded(
      child: Query(
        options: QueryOptions(document: gql(query), variables: {
          'categoryId': widget.categoryId.toString(),
          'currentPage': currentP,
        }),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Center(child: Text('Loading'));
          }
          items = result.data?['products']?['items'];

          wishlistItems = result.data?['wishlist']['items'];

          for (var i = 0; i < wishlistItems!.length; i++) {
            wishlistItemsSku.add(wishlistItems![i]['product']['sku']);
          }

          if (items == null) {
            return const Center(
              child: Text('No Data found.'),
            );
          }

          FetchMoreOptions opts = FetchMoreOptions(
            variables: {
              'currentPage': ++currentP,
            },
            updateQuery: (previousResultData, fetchMoreResultData) {
              final List<dynamic> repos = [
                ...previousResultData?['products']['items'] as List<dynamic>,
                ...fetchMoreResultData?['products']['items'] as List<dynamic>
              ];

              fetchMoreResultData?['products']['items'] = repos;

              return fetchMoreResultData;
            },
          );

          return Column(
            children: [
              sortFilterBar(result.data?['products']['total_count']),
              Expanded(
                child: NotificationListener(
                  child: GridView.count(
                    crossAxisCount: certainPlatformGridCount(),
                    childAspectRatio: 0.5,
                    controller: _scrollController,
                    children: List.generate(items!.length, (index) {
                      return productsList(context, items![index]);
                    }),
                  ),
                  onNotification: (t) {
                    if (t is ScrollEndNotification) {
                      if (_scrollController.position.pixels ==
                          _scrollController.position.maxScrollExtent) {
                        fetchMore!(opts);
                      }
                    }

                    return true;
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget productsList(BuildContext context, item) => Container(
        // padding: const EdgeInsets.all(5.0),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(
                title: item['name'],
                sku: item['sku'],
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: item['image']['url'],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      child: (wishlistItemsSku.contains(item['sku']))
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red.shade600,
                            )
                          : const Icon(
                              Icons.favorite_border,
                            ),
                      onTap: () async {
                        await addProductToWishlistMutation(
                            widget.wishlistId, item['sku']);

                        setState(() {
                          if (wishlistItemsSku.contains(item['sku'])) {
                            // mutation will run here
                            // on re-rendering, it'll itself display the colored/non-colored
                            // heart based on the logic
                          } else {
                            // query will run here
                          }
                        });
                      },
                    ),
                  )
                ],
              ),
              Container(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              item['name'].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xff4A5B6D),
                              ),
                            ),
                            Text(
                              item['description']["html"],
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Color(0xffA5ADB6),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 5.0),
                                child: Text(
                                  currencyWithPrice(item['price_range']
                                      ['minimum_price']['final_price']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xff4A5B6D),
                                  ),
                                ),
                              ),
                              Text(
                                currencyWithPrice(item['price_range']
                                    ['minimum_price']['regular_price']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xffA5ADB6),
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Color(0xffA5ADB6),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${item['price_range']['minimum_price']['discount']['percent_off'].toString()}% OFF",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xff4A5B6D),
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            ],
          ),
        ),
      );

  Container searchBar() {
    return Container(
        margin: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(10),
                hintText: 'Search here...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xffA5ADB6),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SvgPicture.asset(
                    'assets/icons/search.svg',
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(
                    color: Color(0xffEEF2F5),
                    width: 11,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Color(0xff4A5B6D),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          child: IconButton(
            color: Colors.black,
            icon: SvgPicture.asset(
              'assets/icons/back_button.svg',
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
    );
  }
}
