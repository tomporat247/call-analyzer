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
  bool _loadedBannerAd = true;

  AdmobService() {
    _banner = BannerAd(
        adUnitId: _bannerAdUnitID,
        size: AdSize.banner,
        targetingInfo: _targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd event is $event");
          if (event == MobileAdEvent.failedToLoad) {
            _loadedBannerAd = false;
          }
        });
  }

  showBanner() async {
    _banner
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  int getBannerAdHeight() {
    return _loadedBannerAd ? AdSize.banner.height : 0;
  }
}
