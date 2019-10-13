import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/permissions/pages/permission_request.dart';
import 'package:call_analyzer/permissions/services/permission_service.dart';
import 'package:call_analyzer/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  _registerServices();
  runApp(MyApp());
}

_registerServices() {
  GetIt.instance.registerSingleton<PermissionService>(PermissionService());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _pageToDisplay;
  PermissionService _permissionService = GetIt.instance<PermissionService>();

  @override
  void initState() {
    _pageToDisplay = Container();
    _determinePageToDisplay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: appTheme,
      home: _pageToDisplay,
    );
  }

  _determinePageToDisplay() async {
    if (!(await _permissionService.hasRequiredPermissions())) {
      List<PermissionGroup> grantedPermissions =
          await _permissionService.getGrantedPermissions();
      setState(() {
        _pageToDisplay =
            new PermissionRequest(grantedPermissions: grantedPermissions);
      });
    } else {
      setState(() {
        _pageToDisplay = new SplashScreen();
      });
    }

    Future.wait([]).then((List answers) {});
  }
}
