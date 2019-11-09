import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsService {
  FirebaseAnalytics _analytics = FirebaseAnalytics();

  FirebaseAnalytics get analytics => _analytics;

  FirebaseAnalyticsObserver get analyticsObserver =>
      FirebaseAnalyticsObserver(analytics: analytics);

  logAppOpen() {
    _analytics.logAppOpen();
  }

  logEvent({String name, Map<String, dynamic> parameters}) {
    _analytics.logEvent(name: name, parameters: parameters);
  }

  logCurrentScreen(String screenName) {
    _analytics.setCurrentScreen(screenName: screenName);
  }
}
