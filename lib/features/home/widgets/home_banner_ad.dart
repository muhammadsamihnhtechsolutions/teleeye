// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class HomeBannerAd extends StatefulWidget {
//   const HomeBannerAd({super.key});

//   @override
//   State<HomeBannerAd> createState() => _HomeBannerAdState();
// }

// class _HomeBannerAdState extends State<HomeBannerAd> {
//   BannerAd? _bannerAd;
//   bool _isLoaded = false;

//   bool get _isSupportedPlatform {
//     if (kIsWeb) return false;
//     return defaultTargetPlatform == TargetPlatform.android ||
//         defaultTargetPlatform == TargetPlatform.iOS;
//   }

//   String get _adUnitId {
//     if (!_isSupportedPlatform) return '';
//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         return 'ca-app-pub-3940256099942544/6300978111';
//       case TargetPlatform.iOS:
//         return 'ca-app-pub-3940256099942544/2934735716';
//       default:
//         return '';
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     if (!_isSupportedPlatform) return;

//     final adUnitId = _adUnitId;
//     if (adUnitId.isEmpty) return;

//     _bannerAd = BannerAd(
//       adUnitId: adUnitId,
//       request: const AdRequest(),
//       size: AdSize.largeBanner,
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           if (!mounted) return;
//           setState(() => _isLoaded = true);
//           if (kDebugMode) {
//             debugPrint('[ADS] BannerAd loaded: ${ad.responseInfo}');
//           }
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           if (!mounted) return;
//           setState(() => _bannerAd = null);
//           if (kDebugMode) debugPrint('[ADS] BannerAd failed: $error');
//         },
//       ),
//     )..load();
//   }

//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isSupportedPlatform) return const SizedBox.shrink();

//     final ad = _bannerAd;
//     if (!_isLoaded || ad == null) return const SizedBox.shrink();

//     return Center(
//       child: SizedBox(
//         width: ad.size.width.toDouble(),
//         height: ad.size.height.toDouble(),
//         child: AdWidget(ad: ad),
//       ),
//     );
//   }
// }

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class HomeBannerAd extends StatefulWidget {
//   const HomeBannerAd({super.key});

//   @override
//   State<HomeBannerAd> createState() => _HomeBannerAdState();
// }

// class _HomeBannerAdState extends State<HomeBannerAd> {
//   static BannerAd? _bannerAd; // ✅ IMPORTANT: static
//   static bool _isLoaded = false;

//   bool get _isSupportedPlatform {
//     if (kIsWeb) return false;
//     return defaultTargetPlatform == TargetPlatform.android ||
//         defaultTargetPlatform == TargetPlatform.iOS;
//   }

//   String get _adUnitId {
//     if (!_isSupportedPlatform) return '';
//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         return 'ca-app-pub-3940256099942544/6300978111';
//       case TargetPlatform.iOS:
//         return 'ca-app-pub-3940256099942544/2934735716';
//       default:
//         return '';
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     if (!_isSupportedPlatform) return;

//     // ✅ already loaded → dobara mat banao
//     if (_bannerAd != null) return;

//     final adUnitId = _adUnitId;
//     if (adUnitId.isEmpty) return;

//     _bannerAd = BannerAd(
//       adUnitId: adUnitId,
//       request: const AdRequest(),
//       size: AdSize.largeBanner,
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           if (kDebugMode) {
//             debugPrint('[ADS] Banner loaded');
//           }
//           if (mounted) {
//             setState(() {
//               _isLoaded = true;
//             });
//           }
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           _bannerAd = null;
//           _isLoaded = false;
//           if (kDebugMode) {
//             debugPrint('[ADS] Banner failed: $error');
//           }
//         },
//       ),
//     )..load();
//   }

//   @override
//   void dispose() {
//     // ❌ dispose yahan mat karo warna rebuild pe crash ayega
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isSupportedPlatform) return const SizedBox.shrink();

//     if (!_isLoaded || _bannerAd == null) {
//       return const SizedBox.shrink();
//     }

//     return Center(
//       child: SizedBox(
//         width: _bannerAd!.size.width.toDouble(),
//         height: _bannerAd!.size.height.toDouble(),
//         child: AdWidget(ad: _bannerAd!),
//       ),
//     );
//   }
// }
