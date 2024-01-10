import 'package:flutter/material.dart';
import 'package:magento_flutter/CustomWidgets/product_card.dart';

class HorizontalProductView extends StatefulWidget {
  final String viewType;
  final List<Map<String, dynamic>> data;
  const HorizontalProductView(
      {super.key, required this.viewType, required this.data});
  State<HorizontalProductView> createState() => _HorizontalProductView();
}

// This is the horizonal Scroller of product list
class _HorizontalProductView extends State<HorizontalProductView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.viewType,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            const SizedBox(height: 16),
            SizedBox(
                height: 450,
                child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.data.length,
                    itemBuilder: (context, index) => SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: ProductCard(
                            sku: widget.data[index]['sku'],
                            productName: widget.data[index]['productName'],
                            description: widget.data[index]['description'],
                            productImages: widget.data[index]['productImages'],
                            productPrice: widget.data[index]["finalPrice"],
                            regularPrice: widget.data[index]['regularPrice'],
                            isAddedToWishList: true,
                            discountPercentOff: widget.data[index]
                                ['discountPercentOff'])),
                    separatorBuilder: (context, index) => const SizedBox()))
          ],
        ));
  }
}
