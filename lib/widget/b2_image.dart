import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class B2Image extends StatelessWidget {
  final String? objectKey;
  final BoxFit fit;
  final Alignment alignment; // 1. Ajout de l'alignement
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const B2Image({
    super.key,
    required this.objectKey,
    this.fit = BoxFit.cover,
    this.alignment = const Alignment(0.0, -0.25), // 2. Valeur par défaut décalée de 5% vers le haut
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (objectKey == null || objectKey!.isEmpty) {
      return errorWidget ?? const Icon(Icons.broken_image_outlined);
    }

    final url = 'https://lumiconte-cdn.clementfourment.fr/$objectKey';

    Widget image = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      alignment: alignment, // 3. Transmission à CachedNetworkImage
      width: width,
      height: height,
      placeholder: (context, url) =>
          placeholder ??
          const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ?? const Icon(Icons.broken_image_outlined),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: image,
    );
  }
}