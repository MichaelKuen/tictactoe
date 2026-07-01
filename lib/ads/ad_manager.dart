// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _gameCount = 0;
  bool _ready = false;

  static bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // --- Google test ad unit IDs (replace with real IDs before release) ---
  static String get _interstitialId =>
      defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';

  static String get _rewardedId =>
      defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';

  Future<void> initialize() async {
    if (!_supported) return;
    await MobileAds.instance.initialize();
    _ready = true;
    _loadInterstitial();
    _loadRewarded();
  }

  bool get isRewardedReady => _rewardedAd != null;

  // Called by GameScreen on game over. Shows interstitial every 3rd game.
  void onGameEnded() {
    if (!_ready) return;
    _gameCount++;
    if (_gameCount % 3 == 0 && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  void showRewarded(void Function() onEarned) {
    if (_rewardedAd == null) return;
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) => onEarned(),
    );
    _rewardedAd = null;
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) => _loadInterstitial(),
      ),
    );
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _loadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _rewardedAd = null;
              _loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (_) => _loadRewarded(),
      ),
    );
  }
}
