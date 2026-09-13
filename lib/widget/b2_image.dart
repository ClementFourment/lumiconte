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
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  // Garde l'image précédente affichée pendant le chargement de la nouvelle
  final bool useOldImageOnUrlChange;

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
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.useOldImageOnUrlChange = false,
  });

  static String urlFor(String objectKey) =>
      'https://lumiconte-cdn.clementfourment.fr/$objectKey';

  @override
  Widget build(BuildContext context) {
    if (objectKey == null || objectKey!.isEmpty) {
      return errorWidget ?? const Icon(Icons.broken_image_outlined);
    }

    final url = urlFor(objectKey!);

    Widget image = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      alignment: alignment, // 3. Transmission à CachedNetworkImage
      width: width,
      height: height,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      useOldImageOnUrlChange: useOldImageOnUrlChange,
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