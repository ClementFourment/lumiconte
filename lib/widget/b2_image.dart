import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lumiconte/services/storage_service.dart';

/// Affiche une image privée stockée sur Backblaze B2, en gérant
/// automatiquement le chargement, les erreurs, et le cache.
///
/// Usage :
/// ```dart
/// B2Image(
///   objectKey: "https://lumiconte.s3.eu-central-003.backblazeb2.com/story_cover/testtest.png",
///   fit: BoxFit.cover,
/// )
/// ```

class B2Image extends StatelessWidget {
  final String? objectKey;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const B2Image({
    super.key,
    required this.objectKey,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Double-check en runtime
    if (objectKey == null || (objectKey != null && objectKey == "")) {
      return SizedBox(
        width: width,
        height: height,
        child: errorWidget ??
            const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
      );
    }

    Widget content = FutureBuilder<Uint8List>(
      future: StorageService.fetchObjectCached(objectKey!),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return placeholder ??
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return errorWidget ??
              const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.grey),
              );
        }
        return Image.memory(
          snapshot.data!,
          fit: fit,
          width: width,
          height: height,
        );
      },
    );

    return SizedBox(
      width: width,
      height: height,
      child: borderRadius != null
          ? ClipRRect(borderRadius: borderRadius!, child: content)
          : content,
    );
  }
}
