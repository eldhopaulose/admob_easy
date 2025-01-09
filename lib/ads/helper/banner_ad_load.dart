import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../admob_easy.dart';
import '../utils/admob_easy_logger.dart';

class BannerAdEasyLoad {
  static final BannerAdEasyLoad _instance = BannerAdEasyLoad._internal();
  factory BannerAdEasyLoad() => _instance;
  BannerAdEasyLoad._internal();

  BannerAd? admobBannerAd;
  final ValueNotifier<bool> isAdLoading = ValueNotifier(true);
  String? _customId;

  // Getter for the actual ad unit ID to use
  String get _effectiveAdUnitId => _customId ?? AdmobEasy.instance.bannerAdID;

  // Method to set custom ID
  void setCustomId(String? customId) {
    _customId = customId;
  }

  Future<void> init({
    required AdSize adSize,
    required bool isCollapsible,
    required CollapseGravity collapseGravity,
    String? customId,
  }) async {
    // Set custom ID if provided
    setCustomId(customId);

    if (!AdmobEasy.instance.isConnected.value ||
        (_customId?.isEmpty ??
            false && AdmobEasy.instance.bannerAdID.isEmpty)) {
      AdmobEasyLogger.error(
          'Banner ad cannot load: No valid ad unit ID available');
      isAdLoading.value = false;
      return;
    }

    _loadBannerAd(
      adSize: adSize,
      isCollapsible: isCollapsible,
      collapseGravity: collapseGravity,
    );
  }

  void _loadBannerAd({
    required AdSize adSize,
    required bool isCollapsible,
    required CollapseGravity collapseGravity,
  }) {
    isAdLoading.value = true;
    admobBannerAd?.dispose();

    admobBannerAd = BannerAd(
      adUnitId: _effectiveAdUnitId,
      request: AdRequest(
        extras: isCollapsible ? {"collapsible": collapseGravity.name} : null,
      ),
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          admobBannerAd = ad as BannerAd;
          isAdLoading.value = false;
        },
        onAdFailedToLoad: (ad, error) {
          AdmobEasyLogger.error("Failed to load ad ${error.message}");
          ad.dispose();
          admobBannerAd = null;
          isAdLoading.value = false;
          // Retry loading the ad after some delay
          Future.delayed(
            const Duration(seconds: 10),
            () => _loadBannerAd(
              adSize: adSize,
              isCollapsible: isCollapsible,
              collapseGravity: collapseGravity,
            ),
          );
        },
      ),
    );

    admobBannerAd!.load();
  }

  Future<void> dispose() async {
    admobBannerAd?.dispose();
    isAdLoading.dispose();
  }
}
