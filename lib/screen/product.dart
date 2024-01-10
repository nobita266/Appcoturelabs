import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:magento_flutter/CustomWidgets/horizonal_product_view.dart';
import 'package:magento_flutter/CustomWidgets/image_slider.dart';

class ProductScreen extends StatefulWidget {
  final String title;
  final String sku;
  const ProductScreen({super.key, required this.title, required this.sku});
  @override
  State<ProductScreen> createState() => _Product();
}

class _Product extends State<ProductScreen> {
  String selectedSize = '';

  // _Product({ super.key, this.sku})
  List<String> productImages = [];
  Map<String, String> availableOptions = {};
  // ignore: non_constant_identifier_names
  List<Map<String, dynamic>> productDetailedDescription = [];
  Map<String, String> stylingBlockContent = {};
  // query for the products
  static const query = r'''
query GetProductsBySKU($sku: String = "FP-13358") {
    products(filter: { sku: { eq: $sku } }) {
        items {
            __typename
            price_range {
                maximum_price {
                    regular_price {
                        currency
                        value
                    }
                    fixed_product_taxes {
                        label
                        amount {
                            currency
                            value
                        }
                    }
                    final_price {
                        currency
                        value
                    }
                    discount {
                        percent_off
                    }
                }
            }
            media_gallery {
                url
            }
            related_products {
                sku
                name
                media_gallery {
                    url
                }
                price_range {
                    maximum_price {
                        regular_price {
                            currency
                            value
                        }
                        fixed_product_taxes {
                            label
                            amount {
                                currency
                                value
                            }
                        }
                        final_price {
                            currency
                            value
                        }
                        discount {
                            percent_off
                        }
                    }
                }
                short_description {
                    html
                }
            }
            description {
                html
            }
            ... on ConfigurableProduct {
                variants {
                    product {
                        sku
                    }
                    attributes {
                        label
                        code
                    }
                }
            }
            name
            country_of_manufacture
            fabric_material
            sleeve_type
            what_s_in_the_box
            neckline
            fit_type
            color_family
            pattern_print
            options_container
            style_number
            care_instruction
            collection_name
            climate
            short_description {
                html
            }
            description {
                html
            }
            amasty_rewards_highlights {
                caption_color
                visible
                caption_text
            }
            amasty_rewards_guest_highlights {
                caption_color
                caption_text
                visible
            }
            crosssell_products {
                size_numerals
            }
            product_links {
                link_type
                linked_product_sku
                linked_product_type
                position
                sku
            }
        }
    }
    cmsBlocks(
        identifiers: [
            "flutter_block"
            "product-info-delivery-content-info"
            "size_chart_block"
            "return-exchange-policy-block"
            "shipping-info-block"
            "flutter_product_reward_points_block"
            "flutter_product_delivery_details"
        ]
    ) {
        items {
            content
            identifier
            title
        }
    }
}
''';

// function to get PDP Page

  List<Map<String, String>> getFullProductDiscription(dynamic productData) {
    List<Map<String, String>> productDescription = [];

    // product description of the product

    productDescription.addAll([
      {"Collection Name": productData['collection_name'].toString()},
      {"Season": productData['climate'].toString()},
      {"What's in the Box": productData['what_s_in_the_box'].toString()},
      {"Fabric material": productData['fabric_material'].toString()},
      {"Sleeve Length": productData['sleeve_type'].toString()},
      {"Neckline": productData["neckline"].toString()},
      // {"Bottom Length": "Full Length"},
      {"Care Instruction": productData['care_instruction'].toString()},
      {"Style Number": productData['style_number'].toString()},
      {"Country of Origin": productData['country_of_manufacture'].toString()},
      {"Color Family": productData["color_family"].toString()},
      {"Sleeve Type": productData['sleeve_type'].toString()},
      {"Fit Type": productData['fit_type'].toString()},
      {"Pattern Print": productData['pattern_print'].toString()},
      //   {"Occasion": "Casual"}
    ]);

    return productDescription;
  }

// widget builder function required to buld the Build
  @override
  Widget build(BuildContext context) {
    // product size selected by user

    //  List of all the sizes available with there 'sku' ids for the product
// to get the list of all images avilable of the product
    List<String> getAllImages(dynamic images) {
      // ignore: non_constant_identifier_names
      List<String> ImageList = [];
      images.forEach((element) {
        if (element['url'].toString().isNotEmpty) {
          ImageList.add(element?['url']);
        }
      });
      return ImageList;
    }

// to get all available product sizes available

    Map<String, String> getAllSizes(dynamic sizeList) {
      Map<String, String> items = {};
      for (final item in sizeList) {
        items.addAll({
          item['attributes'][0]['label'].toString():
              item['product']['sku'].toString()
        });
      }
      return items;
    }

    // to refetch data after user select any configurable product
    Map<String, String> cmsContentHandler(List<dynamic> stylingCMSBlock) {
      Map<String, String> stylingTipsData = {};
      var unEscape = HtmlUnescape();
      for (var element in stylingCMSBlock) {
        stylingTipsData.addAll(
            {element['identifier']: unEscape.convert(element['content'])});
      }
      return stylingTipsData;
    }

    FetchMoreOptions getFetchMoreOptions(String? newSku) {
      return FetchMoreOptions(
          variables: {'sku': newSku},
          updateQuery: ((previousResultData, fetchMoreResultData) {
            return fetchMoreResultData;
          }));
    }

// function which return the rearranged data for horizontalViewData

    List<Map<String, dynamic>> horizontalViewData(List<dynamic> data) {
      List<Map<String, dynamic>> viewData = [];

// to re-arrage the data for suggetions and upsell product
      for (var element in data) {
        viewData.add({
          "sku": element['sku'],
          "productName": element["name"],
          "description": element["short_description"]['html'],
          "productImages": element['media_gallery'],
          "finalPrice": element['price_range']?['maximum_price']?['final_price']
                  ['currency'] +
              " " +
              element['price_range']?['maximum_price']?['final_price']['value']
                  .toString(),
          "regularPrice": element['price_range']?['maximum_price']
                  ?['regular_price']['currency'] +
              " " +
              element['price_range']?['maximum_price']?['regular_price']
                      ['value']
                  .toString(),
          "discountPercentOff": element['price_range']?['maximum_price']
                  ?['discount']['percent_off']
              .toString()
        });
      }
      return viewData;
    }

    // Function to render reviews of the user in product page

    // ignore: unused_element
    Widget customerReviews(String reviewTitle, String review, String reviewBy,
        String reviewDate, int ratings) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reviewTitle,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff4A5B6D))),
          const SizedBox(height: 10),
          Text(review,
              style: const TextStyle(fontSize: 12, color: Color(0xffA5ADB6))),
          const Text("Thank You!",
              style: TextStyle(fontSize: 12, color: Color(0xffA5ADB6))),
          const SizedBox(height: 20),
          Row(children: [
            Row(children: [
              Text(reviewBy,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xff4A5B6D))),
              const SizedBox(width: 15),
              Text(reviewDate,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xff4A5B6D)))
            ]),
          ])
        ],
      );
    }

    // function to return a widgets to render product specific offers.

    Widget productSpecificOffers(
        Widget icon, String offerTitle, String offerDiscription) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 12),
              // dynamic offers
              Text(offerTitle,
                  style: const TextStyle(
                      color: Color(0xff4A5B6D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500))
            ],
          ),
          const SizedBox(height: 6),
          Text(
            offerDiscription,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff4A5B6D)),
          )
        ],
      );
    }

    // function to return

// function to return widget in key value pair for product description

    // ignore: non_constant_identifier_names
    Widget showDescription(String key, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 15,
              child: Text(key,
                  style:
                      const TextStyle(color: Color(0xffA5ADB6), fontSize: 14))),
          SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 15,
              child: Text(value,
                  style: const TextStyle(
                      color: Color(0xff4A5B6D), fontWeight: FontWeight.w500)))
        ],
      );
    }

    Widget cmsBlockRenderer(String content) {
      return HtmlWidget(content);
      // return Html(data: );
    }

// Function of type Widget to which return a expandable widget
    // ignore: non_constant_identifier_names
    Widget dropDownWidget(
        String title, String description, List<dynamic> itemList) {
      return ExpansionTile(
          tilePadding: const EdgeInsets.all(0),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          children: [
            description.isNotEmpty
                ? Text(description,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xffA5ADB6)))
                : const SizedBox(),
            description.isNotEmpty
                ? const SizedBox(height: 24)
                : const SizedBox(),
            itemList.isNotEmpty
                ? Column(children: [
                    SizedBox(
                        // need to figure it out how to handle content of dynamic height and rewrite the logic for the same

                        child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 12, bottom: 16),
                            itemBuilder: (context, index) {
                              return title == "Description"
                                  ? itemList[index].values.elementAt(0) !=
                                              "null" &&
                                          itemList[index]
                                              .values
                                              .elementAt(0)
                                              .toString()
                                              .isNotEmpty
                                      ? showDescription(
                                          itemList[index].keys.elementAt(0),
                                          itemList[index].values.elementAt(0))
                                      : const SizedBox()
                                  : cmsBlockRenderer(itemList[index = 0]);
                            },
                            itemCount: itemList.length,
                            separatorBuilder: (context, index) =>
                                itemList[index].values.elementAt(0) != "null" &&
                                        itemList[index]
                                            .values
                                            .elementAt(0)
                                            .toString()
                                            .isNotEmpty
                                    ? const SizedBox(height: 10)
                                    : const SizedBox())),
                  ])
                : const SizedBox(width: 0, height: 0),
          ]);
    }

// size guide

    Future openDialog(String cmsContent) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              elevation: BorderSide.strokeAlignCenter,
              scrollable: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              content: cmsBlockRenderer(cmsContent),
            ));

    return Scaffold(
        appBar: AppBar(),
        body: Query(
          options: QueryOptions(
              document: gql(query), variables: {"sku": widget.sku}),
          builder: ((result, {fetchMore, refetch}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }
            if (result.isLoading) {
              return const Center(child: Text('Loading...'));
            }

            // storing product detail in a variable
            dynamic items = result.data?['products']['items']?[0];
            // storing cms block in a variable.
            stylingBlockContent =
                cmsContentHandler(result.data?['cmsBlocks']['items']);

            // function call to get all list of images
            productImages = getAllImages(items['media_gallery']);

            // function to get all available sites available for the product
            availableOptions = getAllSizes(items['variants']);

            // function to get the complete description of the product
            productDetailedDescription = getFullProductDiscription(items);

            // function to get the complete description of the product
            productDetailedDescription = getFullProductDiscription(items);
            return SingleChildScrollView(
                child: Column(
              children: [
                ImageSlider(
                    imageList: productImages,
                    sliderHeight: MediaQuery.of(context).size.height - 300,
                    pageIndectorWidth: 8,
                    pageIndectorHeight: 8),

                Container(
                    width: double.maxFinite,
                    decoration: const BoxDecoration(color: Colors.white),
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, top: 12, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(items?['name'],
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff4A5B6D))),
                        const SizedBox(height: 10),
                        Text(items?['short_description']?['html'],
                            style: const TextStyle(color: Color(0xffA5ADB6))),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Text(
                                  "${items['price_range']['maximum_price']['final_price']['currency']} ${items['price_range']['maximum_price']['final_price']['value']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              const SizedBox(width: 10),

                              // render 'regular price' Text Widget according to 'regular price' and 'final price' of the product i.e 'regular price' must not be greater then 'final price'

                              items['price_range']['maximum_price']
                                          ['regular_price']['value'] >
                                      items['price_range']['maximum_price']
                                          ['final_price']['value']
                                  ? Text(
                                      "${items['price_range']['maximum_price']['regular_price']['currency']} ${items['price_range']['maximum_price']['regular_price']['value']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Color(0xffA5ADB6)))
                                  : const SizedBox(width: 0),

                              // to spacing b/w widget according to the above logic

                              items['price_range']['maximum_price']
                                          ['regular_price']['value'] >
                                      items['price_range']['maximum_price']
                                          ['final_price']['value']
                                  ? const SizedBox(width: 10)
                                  : const SizedBox(width: 0),
                              const Text("(Incl VAT)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                      color: Color(0xffA5ADB6)))
                            ]),

                            // rendering 'discont percentage' widget if discount is greater then '0%'
                            items['price_range']['maximum_price']['discount']
                                        ['percent_off'] >
                                    0.0
                                ? Text(
                                    items['price_range']['maximum_price']
                                                ['discount']['percent_off']
                                            .toString() +
                                        '% off'.toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xff4A5B6D)))
                                : const SizedBox(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff4A5B6D),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                padding: const EdgeInsets.all(12)),
                            child: const Center(
                                child: Text("ADD TO BAG",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)))),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(IconData(0xf44a, fontFamily: 'MaterialIcons'),
                                color: Colors.grey),
                            SizedBox(width: 5),
                            Text(
                              "Order in ${"1 hrs 15 mins"} to receive product today",
                            )
                          ],
                        ),
                        const SizedBox(height: 10),

                        const Divider(thickness: 1, color: Colors.grey),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Select Size",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xff4A5B6D),
                                fontSize: 16,
                              ),
                            ),

                            // A custom selector to render product sizes available
                            const SizedBox(height: 20),
                            Row(children: [
                              SizedBox(
                                  width: 280,
                                  height: 34,
                                  child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                            onTap: () => {
                                                  setState(() {
                                                    selectedSize =
                                                        availableOptions.keys
                                                            .elementAt(index);
                                                    if (fetchMore != null) {
                                                      fetchMore(getFetchMoreOptions(
                                                          availableOptions[
                                                                  selectedSize] ??
                                                              ''));
                                                    }
                                                  })
                                                },
                                            child: Container(
                                              // ignore: unrelated_type_equality_checks
                                              decoration: selectedSize
                                                          .toString() ==
                                                      availableOptions.keys
                                                          .elementAt(index)
                                                  ? BoxDecoration(
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors.black))
                                                  : BoxDecoration(
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors
                                                              .grey.shade400)),
                                              width: 36,
                                              child: Center(
                                                  child: Text(availableOptions
                                                      .keys
                                                      .elementAt(index))),
                                            ));
                                      },
                                      itemCount: availableOptions.keys.length,
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(width: 20);
                                      })),
                              const SizedBox(width: 10),
                              stylingBlockContent['size_chart_block']!
                                      .isNotEmpty
                                  ? InkWell(
                                      child: const Text(
                                        "Size Guide",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                      onTap: () {
                                        openDialog(stylingBlockContent[
                                            'size_chart_block']!);
                                      },
                                    )
                                  : const SizedBox()
                            ]),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Divider(
                            thickness: 1,
                            height: 2,
                            color: Colors.grey.shade400),
                        const SizedBox(height: 11),
                        cmsBlockRenderer(stylingBlockContent[
                            'flutter_product_reward_points_block']!),
                        const SizedBox(height: 15),
                        const Divider(thickness: 1, height: 2),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Want to pay in instalments?"),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(188, 48),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.all(Radius.zero))),
                                    onPressed: () {},
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("postpay",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 24,
                                                color: Colors.black)),
                                        SizedBox(width: 10),
                                        Icon(IconData(0xe33d,
                                            fontFamily: 'MaterialIcons'))
                                      ],
                                    )),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(188, 48),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.all(Radius.zero))),
                                    onPressed: () {},
                                    child: const Center(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("tabby",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 24,
                                                color: Colors.black)),
                                        SizedBox(width: 10),
                                        Icon(IconData(0xe33d,
                                            fontFamily: 'MaterialIcons'))
                                      ],
                                    )))
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Divider(thickness: 1, height: 2),
                        cmsBlockRenderer(stylingBlockContent[
                            "flutter_product_delivery_details"]!),
                        const Divider(thickness: 1, height: 2),
                        const SizedBox(height: 15),
                        cmsBlockRenderer(stylingBlockContent[
                            'product-info-delivery-content-info']!),
                        const SizedBox(height: 15),
                        const Divider(thickness: 1, height: 2),
                        const SizedBox(height: 15),
                        productSpecificOffers(
                            const Icon(
                                IconData(0xe13e, fontFamily: 'MaterialIcons'),
                                color: Color(0xffA5ADB6)),
                            "Free Gift",
                            "Shop for AED 500 & Get Free Gift"),
                        const SizedBox(height: 15),
                        items?['description']?['html'].toString() != null
                            ? dropDownWidget(
                                "Description",
                                items?['description']?['html'],
                                productDetailedDescription)
                            : const SizedBox(),
                        stylingBlockContent['flutter_block']!.isNotEmpty
                            ? dropDownWidget("Styling Tips", "",
                                [stylingBlockContent['flutter_block']])
                            : const SizedBox(),
                        stylingBlockContent.isNotEmpty
                            ? dropDownWidget("Shiping info", "",
                                [stylingBlockContent['shipping-info-block']])
                            : const SizedBox(),
                        stylingBlockContent.isNotEmpty
                            ? dropDownWidget("Return & Exchange Policy", "", [
                                stylingBlockContent[
                                    'return-exchange-policy-block']
                              ])
                            : const SizedBox(),

                        // dropdownWidget for customer review scrtion
                        // custom widget to show customer reviews

                        // customerReviews(
                        //     "Elegant and beautiful",
                        //     "A beige maxi dress in a cheetah print, made from 100% viscose and features a straight sleeves and v-neckline with tieup necklineThank you!",
                        //     "Shedley",
                        //     "Aug 25, 2022",
                        //     4),
                        const SizedBox(height: 20),
                      ],
                    )),

                // Product Suggetion Section based on the pdp

                // related Products

                items['related_products'].length > 0
                    ? HorizontalProductView(
                        viewType: "You May Also Like",
                        data: horizontalViewData(items['related_products']))
                    : const SizedBox()

                // cross sell products
                //     HorizontalProductView(
                //     viewType: "Personalized for you", data: horizontalViewData())
              ],
            ));
          }),
        ));
  }
}
