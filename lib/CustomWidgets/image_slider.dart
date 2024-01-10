import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageSlider extends StatelessWidget {
  List<String> imageList = [];
  final double sliderHeight;
  final double pageIndectorHeight;
  final double pageIndectorWidth;
  ImageSlider(
      {super.key,
      required this.imageList,
      required this.sliderHeight,
      required this.pageIndectorHeight,
      required this.pageIndectorWidth});

  final dynamic controller =
      PageController(viewportFraction: 16 / 9, keepPage: true);

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(
        imageList.length,
        (index) => SizedBox(
              height: sliderHeight,
              child: SizedBox(child: Image.network(imageList[index])),
            ));
    return SafeArea(
        child: Stack(alignment: Alignment.center, children: [
      SizedBox(
        height: sliderHeight,
        child: PageView.builder(
          controller: controller,
          itemCount: pages.length,
          itemBuilder: (context, index) {
            return pages[index % pages.length];
          },
        ),
      ),
      Positioned(
          bottom: 20,
          child: SmoothPageIndicator(
              controller: controller,
              axisDirection: Axis.horizontal,
              count: pages.length,
              effect: ExpandingDotsEffect(
                // colors that are hardcoded should be in a global variable for the app
                activeDotColor: const Color(0XFF4A5B6D),
                dotHeight: pageIndectorHeight,
                dotWidth: pageIndectorWidth,
              )))
    ]));
  }
}
