import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 통합 싱글톤 - 사용자 경험(UX) 및 Web 호환 최적화 버전
class AdHelper {
  AdHelper._();
  static final AdHelper instance = AdHelper._();

  bool _initialized = false;

  // ── Google Official Test Ad Unit IDs ──
  String get bannerAdUnitId {
    if (kIsWeb) return '';
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';
  }

  String get interstitialAdUnitId {
    if (kIsWeb) return '';
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/1033173712'
        : 'ca-app-pub-3940256099942544/4411468910';
  }

  String get rewardedAdUnitId {
    if (kIsWeb) return '';
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';
  }

  // ═══════════════════════════════════════
  //  SDK 초기화
  // ═══════════════════════════════════════
  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('[AdHelper] MobileAds SDK initialized (UX-Optimized)');
      loadInterstitialAd();
      loadRewardedAd();
    } catch (e) {
      debugPrint('[AdHelper] MobileAds init skipped or failed: $e');
    }
  }

  // ═══════════════════════════════════════
  //  1. Interstitial Ad (분석 완료 시 1회 노출)
  // ═══════════════════════════════════════
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  void loadInterstitialAd() {
    if (kIsWeb || _interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdHelper] Interstitial loaded');
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdHelper] Interstitial failed: ${error.message}');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  void showInterstitialAd({required VoidCallback onComplete}) {
    if (kIsWeb) {
      onComplete();
      return;
    }
    if (_interstitialAd == null) {
      loadInterstitialAd();
      onComplete();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onComplete();
      },
    );
    _interstitialAd!.show();
  }

  // ═══════════════════════════════════════
  //  2. Rewarded Ad (자발적 선택 시에만 노출)
  // ═══════════════════════════════════════
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  void loadRewardedAd() {
    if (kIsWeb || _rewardedAd != null || _isRewardedLoading) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdHelper] Rewarded Ad loaded');
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdHelper] Rewarded Ad failed: ${error.message}');
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(bool rewarded) onResult,
    Function(String)? onError,
  }) {
    if (kIsWeb) {
      onResult(true);
      return;
    }

    if (_rewardedAd == null) {
      loadRewardedAd();
      onError?.call('광고가 준비 중입니다. 잠시 후 다시 시도해 주세요.');
      return;
    }

    bool earned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onResult(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onError?.call('광고 재생 중 오류가 발생했습니다.');
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        earned = true;
      },
    );
  }
}
