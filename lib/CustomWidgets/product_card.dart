import 'package:flutter/material.dart';
import 'package:magento_flutter/CustomWidgets/image_slider.dart';
import 'package:magento_flutter/screen/product.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final String description;
  final List<dynamic> productImages;
  final String productPrice;
  final String regularPrice;
  final String discountPercentOff;
  final String sku;
  final bool isAddedToWishList;
  const ProductCard(
      {super.key,
      required this.sku,
      required this.productName,
      required this.description,
      required this.productImages,
      required this.productPrice,
      required this.regularPrice,
      required this.isAddedToWishList,
      required this.discountPercentOff});
  List<String> imageList(List<dynamic> productImages) {
    List<String> images = [];
    for (var items in productImages) {
      images.add(items['url']);
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(
              title: "Title",
              sku: sku,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ImageSlider(
                    imageList: imageList(productImages),
                    sliderHeight: 300,
                    pageIndectorWidth: 6,
                    pageIndectorHeight: 6),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    child: (isAddedToWishList)
                        ? Icon(
                            Icons.favorite,
                            color: Colors.red.shade600,
                          )
                        : const Icon(
                            Icons.favorite_border,
                          ),
                    onTap: () async {
                      // await addProductToWishlistMutation(
                      //     widget.wishlistId, item['sku']);

                      // setState(() {
                      //   if (wishlistItemsSku.contains(item['sku'])) {
                      //     // mutation will run here
                      //     // on re-rendering, it'll itself display the colored/non-colored
                      //     // heart based on the logic
                      //   } else {
                      //     // query will run here
                      //   }
                      // });
                    },
                  ),
                )
              ],
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        productName.isNotEmpty
                            ? Text(
                                productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color(0XFF4A5B6D)),
                              )
                            : const SizedBox(),
                        productName.isNotEmpty && description.isNotEmpty
                            ? const SizedBox(height: 2)
                            : const SizedBox(),
                        description.isNotEmpty
                            ? Text(
                                description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Color(0XFFA5ADB6),
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : const SizedBox(),
                        description.isNotEmpty && productPrice.isNotEmpty
                            ? const SizedBox(height: 8)
                            : const SizedBox(),
                        Row(children: [
                          productPrice.isNotEmpty
                              ? Text(
                                  productPrice,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0XFF4A5B6D)),
                                )
                              : const SizedBox(),
                          const SizedBox(width: 12),
                          Text(regularPrice,
                              style: const TextStyle(
                                  color: Color(0XFFA5ADB6),
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough))
                        ]),
                        discountPercentOff.isNotEmpty &&
                                double.parse(discountPercentOff) > 0
                            ? Text(
                                "$discountPercentOff% OFF",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
