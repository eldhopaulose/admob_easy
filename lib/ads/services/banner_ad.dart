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
import '../admob_easy.dart';
import '../helper/banner_ad_load.dart';

enum CollapseGravity {
  top,
  bottom,
}

class AdMobBannerWidget extends StatefulWidget {
  final AdSize adSize;
  final bool isCollapsible;
  final CollapseGravity collapseGravity;
  final int position;

  const AdMobBannerWidget({
    Key? key,
    required this.adSize,
    this.isCollapsible = false,
    this.collapseGravity = CollapseGravity.bottom,
    required this.position,
  }) : super(key: key);

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  late final BannerAdManager _adManager;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _adManager = BannerAdManager();
    _loadAd();
  }

  Future<void> _loadAd() async {
    _bannerAd = await _adManager.getAd(
      adUnitId: AdmobEasy.instance.bannerAdID,
      adSize: widget.adSize,
      position: widget.position,
      isCollapsible: widget.isCollapsible,
      collapseGravity: widget.collapseGravity,
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          _adManager.getLoadingState(widget.adSize, widget.position),
      builder: (context, isLoading, child) {
        if (isLoading) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: widget.adSize.width.toDouble(),
              height: widget.adSize.height.toDouble(),
              color: Colors.white,
              alignment: Alignment.topLeft,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFE88F1A),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Padding(
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

        if (_bannerAd == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(
            ad: _bannerAd!,
            key: ValueKey(_bannerAd.hashCode),
          ),
        );
      },
    );
  }
}
