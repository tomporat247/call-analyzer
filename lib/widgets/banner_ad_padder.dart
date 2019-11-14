import 'package:call_analyzer/services/admob_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BannerAdPadder extends Material {
  BannerAdPadder(Widget child)
      : super(
            child: Padding(
                padding: EdgeInsets.only(
                    bottom: GetIt.instance<AdmobService>()
                        .getBannerAdHeight()
                        .toDouble()),
                child: child));
}
