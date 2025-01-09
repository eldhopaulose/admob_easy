import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/banner_ad.dart';

class BannerAdManager {
  static final BannerAdManager _instance = BannerAdManager._internal();
  factory BannerAdManager() => _instance;
  BannerAdManager._internal();

  final Map<String, BannerAd> _adCache = {};
  final Map<String, ValueNotifier<bool>> _loadingStates = {};

  String _getUniqueKey(AdSize adSize, int position) {
    return '${adSize.width}x${adSize.height}_$position';
  }

  Future<BannerAd?> getAd({
    required String adUnitId,
    required AdSize adSize,
    required int position,
    required bool isCollapsible,
    required CollapseGravity collapseGravity,
  }) async {
    final String key = _getUniqueKey(adSize, position);

    if (!_loadingStates.containsKey(key)) {
      _loadingStates[key] = ValueNotifier(true);
    }

    if (_adCache.containsKey(key)) {
      return _adCache[key];
    }

    final BannerAd bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: AdRequest(
        extras: isCollapsible ? {"collapsible": collapseGravity.name} : null,
      ),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _adCache[key] = ad as BannerAd;
          _loadingStates[key]?.value = false;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _adCache.remove(key);
          _loadingStates[key]?.value = false;

          // Retry after delay
          Future.delayed(
            const Duration(seconds: 10),
            () => getAd(
              adUnitId: adUnitId,
              adSize: adSize,
              position: position,
              isCollapsible: isCollapsible,
              collapseGravity: collapseGravity,
            ),
          );
        },
      ),
    );

    try {
      await bannerAd.load();
      _adCache[key] = bannerAd;
      return bannerAd;
    } catch (e) {
      _loadingStates[key]?.value = false;
      return null;
    }
  }

  ValueNotifier<bool> getLoadingState(AdSize adSize, int position) {
    final String key = _getUniqueKey(adSize, position);
    return _loadingStates[key] ?? ValueNotifier(true);
  }

  void dispose() {
    for (var ad in _adCache.values) {
      ad.dispose();
    }
    _adCache.clear();
    for (var loadingState in _loadingStates.values) {
      loadingState.dispose();
    }
    _loadingStates.clear();
  }
}
