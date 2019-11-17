import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';

class AdmobService {
  final String _bannerAdUnitID = 'ca-app-pub-6746638404168860/5335374936';
  MobileAdTargetingInfo _targetingInfo = MobileAdTargetingInfo(
    keywords: <String>[
      'call',
      'analyze',
      'phone',
      'friend',
      'chart',
      'graph',
      'contact'
    ],
    childDirected: false,
  );
  BannerAd _banner;
  bool _bannerAdDisplayed;
  Completer<bool> _loadedAd;

  AdmobService() {
    _loadedAd = new Completer();
    _banner = BannerAd(
        adUnitId: _bannerAdUnitID,
        size: AdSize.banner,
        targetingInfo: _targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd event is $event");
          if (!_loadedAd.isCompleted) {
            _loadedAd.complete(event != MobileAdEvent.failedToLoad);
          }
        });
  }

  Future<void> showBanner() async {
    await _banner.load();
    await _banner.show(anchorType: AnchorType.bottom);
    _bannerAdDisplayed = await _loadedAd.future;
  }

  int getBannerAdHeight() {
    return _bannerAdDisplayed ? AdSize.banner.height : 0;
  }
}
