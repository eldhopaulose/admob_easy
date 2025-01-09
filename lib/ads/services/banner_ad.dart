/*
 ********************************************************************************

    _____/\\\\\\\\\_____/\\\\\\\\\\\\\\\__/\\\\\\\\\\\__/\\\\\\\\\\\\\\\_
    ___/\\\\\\\\\\\\\__\///////\\\/////__\/////\\\///__\/\\\///////////__
    __/\\\/////////\\\_______\/\\\___________\/\\\_____\/\\\_____________
    _\/\\\_______\/\\\_______\/\\\___________\/\\\_____\/\\\\\\\\\\\_____
    _\/\\\\\\\\\\\\\\\_______\/\\\___________\/\\\_____\/\\\///////______
    _\/\\\/////////\\\_______\/\\\___________\/\\\_____\/\\\_____________
    _\/\\\_______\/\\\_______\/\\\___________\/\\\_____\/\\\_____________
    _\/\\\_______\/\\\_______\/\\\________/\\\\\\\\\\\_\/\\\_____________
    _\///________\///________\///________\///////////__\///______________

    Created by Muhammad Atif on 05/01/2024 : 11:51 pm.
    Portfolio https://atifnoori.web.app.
    +923085690603

 ********************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';
import '../helper/banner_ad_load.dart';

enum CollapseGravity {
  top,
  bottom,
}

class AdMobEasyBanner extends StatefulWidget {
  final AdSize adSize;
  final bool isCollapsible;
  final CollapseGravity collapseGravity;

  const AdMobEasyBanner({
    super.key,
    this.adSize = AdSize.banner,
    this.isCollapsible = false,
    this.collapseGravity = CollapseGravity.bottom,
  });

  @override
  State<AdMobEasyBanner> createState() => _AdMobEasyBannerState();
}

class _AdMobEasyBannerState extends State<AdMobEasyBanner> {
  final BannerAdEasyLoad _bannerAd = BannerAdEasyLoad();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _bannerAd.isAdLoading,
      builder: (context, isAdLoading, child) {
        if (isAdLoading) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: widget.adSize.width.toDouble(),
              height: widget.adSize.height.toDouble(),
              color: Colors.white,
              alignment: Alignment.topLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFE88F1A),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Text(
                    'Ad',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (_bannerAd.admobBannerAd == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: _bannerAd.admobBannerAd!.size.width.toDouble(),
          height: _bannerAd.admobBannerAd!.size.height.toDouble(),
          child: AdWidget(
            ad: _bannerAd.admobBannerAd!,
            key: ValueKey(_bannerAd.admobBannerAd!.hashCode),
          ),
        );
      },
    );
  }
}
