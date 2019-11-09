import 'package:call_analyzer/admob/admob_service.dart';
import 'package:flutter/material.dart';

class BannerAdPadder extends Material {
  BannerAdPadder(Widget child)
      : super(
            child: Padding(
                padding: EdgeInsets.only(
                    bottom: AdmobService().getBannerAdHeight().toDouble()),
                child: child));
}
