import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
// import 'package:eye_buddy/app/utils/assets/app_assets.dart';
// import 'package:eye_buddy/app/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/services/api/service/api_constants.dart';

class CommonNetworkImageWidget extends StatelessWidget {
  const CommonNetworkImageWidget({
    required this.imageLink,
    this.boxFit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  final String imageLink;
  final BoxFit boxFit;
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    return builtItemImageContainer(imageLink);
  }

  Widget builtItemImageContainer(String? imageName) {
    var raw = (imageName ?? '').trim();
    final rawLower = raw.toLowerCase();
    final rawUriForValidation = Uri.tryParse(raw);
    final rawSegments = rawUriForValidation?.pathSegments ?? const <String>[];
    final hasInvalidSegment = rawSegments.any(
      (s) => s.toLowerCase() == 'null' || s.toLowerCase() == 'undefined',
    );
    final looksInvalid =
        raw.isEmpty ||
        rawLower == 'null' ||
        rawLower == 'undefined' ||
        hasInvalidSegment;

    String imageUrl = raw;
    final rawUri = Uri.tryParse(raw);
    final rawIsAbsolute = rawUri != null && rawUri.isAbsolute;
    if (!looksInvalid && !rawIsAbsolute) {
      final base = ApiConstants.imageBaseUrl;
      if (raw.startsWith('/')) {
        final normalizedBase = base.endsWith('/')
            ? base.substring(0, base.length - 1)
            : base;
        imageUrl = '$normalizedBase$raw';
      } else {
        final normalizedBase = base.endsWith('/') ? base : '$base/';
        imageUrl = '$normalizedBase$raw';
      }
    }

    final uri = Uri.tryParse(imageUrl);
    final validURL = uri != null && uri.isAbsolute;
    final isBaseOnly = validURL && uri.toString() == ApiConstants.imageBaseUrl;

    try {
      return DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.zero,
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: (validURL && !looksInvalid && !isBaseOnly)
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  useOldImageOnUrlChange: true,
                  memCacheWidth: memCacheWidth,
                  memCacheHeight: memCacheHeight,
                  imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                  errorListener: (error) {
                    unawaited(CachedNetworkImage.evictFromCache(imageUrl));
                  },
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      image: DecorationImage(image: imageProvider, fit: boxFit),
                    ),
                  ),
                  placeholder: (context, url) => const Center(
                    child: CupertinoActivityIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      image: DecorationImage(
                        image: AssetImage(AppAssets.beh_app_icon_with_bg),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    image: DecorationImage(
                      image: AssetImage(AppAssets.beh_app_icon_with_bg),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
        ),
      );
    } catch (error) {
      log('error : $error');
      return Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(100)),
          image: DecorationImage(
            image: AssetImage(AppAssets.beh_app_icon_with_bg),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }
}
