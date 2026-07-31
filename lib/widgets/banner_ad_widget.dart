import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/ad_helper.dart';

/// 고정 높이 Placeholder를 가진 배너 광고 위젯 (Layout Shift 방지, Web 지원)
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.instance.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _isAdLoaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        height: 50,
        alignment: Alignment.center,
        child: Text(
          '✨ ColorFit AI · Personal Color Diagnosis',
          style: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    return Container(
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      alignment: Alignment.center,
      color: Colors.transparent,
      child: _isAdLoaded && _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : Text(
              'AD',
              style: TextStyle(
                color: Colors.white.withOpacity(0.15),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
    );
  }
}
