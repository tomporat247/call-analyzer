import 'package:firebase_admob/firebase_admob.dart';

class AdmobService {
  final String _bannerAdUnitID = 'ca-app-pub-6746638404168860/5335374936';
  MobileAdTargetingInfo _targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['call', 'analyze', 'phone', 'friend'],
    childDirected: false,
    testDevices: <String>[],
  );
  BannerAd _banner;

  AdmobService() {
    _banner = BannerAd(
        adUnitId: _bannerAdUnitID,
        size: AdSize.banner,
        targetingInfo: _targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd event is $event");
        });
  }

  showBanner() {
    _banner
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  int getBannerAdHeight() {
    return AdSize.banner.height;
  }
}
