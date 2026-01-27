import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerCarouselWidget extends StatefulWidget {
  const AdBannerCarouselWidget({Key? key}) : super(key: key);

  @override
  State<AdBannerCarouselWidget> createState() => _AdBannerCarouselWidgetState();
}

class _AdBannerCarouselWidgetState extends State<AdBannerCarouselWidget> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> images = [
    "https://picsum.photos/800/400?random=1",
    "https://picsum.photos/800/400?random=2",
    "https://picsum.photos/800/400?random=3",
  ];

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/6300978111", // Android test ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isAdLoaded)
          SizedBox(
            height: _bannerAd.size.height.toDouble(),
            width: _bannerAd.size.width.toDouble(),
            child: AdWidget(ad: _bannerAd),
          ),

        const SizedBox(height: 10),

        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => Container(
              margin: const EdgeInsets.all(4),
              width: _currentIndex == index ? 12 : 8,
              height: _currentIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
