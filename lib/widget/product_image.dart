import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
class ProductImage extends StatelessWidget {
  const ProductImage({super.key,required this.imageLink});
  final String imageLink;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageLink,
      fit: BoxFit.fitHeight,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.fitHeight,
            colorFilter: const ColorFilter.mode(Colors.transparent, BlendMode.colorBurn),
          ),
        ),
      ),
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
