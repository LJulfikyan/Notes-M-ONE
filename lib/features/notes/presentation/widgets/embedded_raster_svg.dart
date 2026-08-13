import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef _EmbeddedRasterSvgData = ({
  Uint8List bytes,
  double viewportWidth,
  double viewportHeight,
  double imageWidth,
  double imageHeight,
  double scaleX,
  double scaleY,
  double translateX,
  double translateY,
});

final Map<String, Future<_EmbeddedRasterSvgData>> _decodedAssets = {};

Future<_EmbeddedRasterSvgData> _loadEmbeddedImage(String assetPath) {
  return _decodedAssets.putIfAbsent(assetPath, () async {
    final asset = await rootBundle.load(assetPath);
    final svg = utf8.decode(
      asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes),
    );
    final viewport = RegExp(
      r'<svg[^>]*\bwidth="([\d.]+)"[^>]*\bheight="([\d.]+)"',
    ).firstMatch(svg);
    final image = RegExp(
      r'<image[^>]*\bwidth="([\d.]+)"[^>]*\bheight="([\d.]+)"',
    ).firstMatch(svg);
    final transform = RegExp(
      r'transform="matrix\(([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+'
      r'([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\)"',
    ).firstMatch(svg);
    final payload = RegExp(
      r'data:image/[^;]+;base64,([^"\s]+)',
    ).firstMatch(svg);
    if (viewport == null ||
        image == null ||
        transform == null ||
        payload == null) {
      throw FormatException('No embedded raster image found in $assetPath');
    }
    final skewY = double.parse(transform.group(2)!);
    final skewX = double.parse(transform.group(3)!);
    if (skewX != 0 || skewY != 0) {
      throw UnsupportedError('Skewed embedded SVG images are not supported');
    }
    return (
      bytes: base64Decode(payload.group(1)!),
      viewportWidth: double.parse(viewport.group(1)!),
      viewportHeight: double.parse(viewport.group(2)!),
      imageWidth: double.parse(image.group(1)!),
      imageHeight: double.parse(image.group(2)!),
      scaleX: double.parse(transform.group(1)!),
      scaleY: double.parse(transform.group(4)!),
      translateX: double.parse(transform.group(5)!),
      translateY: double.parse(transform.group(6)!),
    );
  });
}

class EmbeddedRasterSvg extends StatelessWidget {
  const EmbeddedRasterSvg({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EmbeddedRasterSvgData>(
      future: _loadEmbeddedImage(assetPath),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return SizedBox(width: width, height: height);
        return SizedBox(
          width: width,
          height: height,
          child: FittedBox(
            fit: fit ?? BoxFit.contain,
            child: ClipRect(
              child: SizedBox(
                width: data.viewportWidth,
                height: data.viewportHeight,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      left: data.translateX * data.viewportWidth,
                      top: data.translateY * data.viewportHeight,
                      width: data.scaleX * data.imageWidth * data.viewportWidth,
                      height:
                          data.scaleY * data.imageHeight * data.viewportHeight,
                      child: Image.memory(
                        data.bytes,
                        fit: BoxFit.fill,
                        gaplessPlayback: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
