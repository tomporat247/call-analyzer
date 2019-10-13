import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/permissions/pages/permission_request.dart';
import 'package:call_analyzer/permissions/services/permission_service.dart';
import 'package:call_analyzer/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
      theme: getAppTheme(context),
      home: _pageToDisplay,
    );
  }

  _determinePageToDisplay() async {
    if (!(await _permissionService.hasRequiredPermissions())) {
      _setPageToDisplay(new PermissionRequest(
        grantedPermissions: await _permissionService.getGrantedPermissions(),
        onAllPermissionsGranted: () => _setPageToDisplay(new SplashScreen()),
      ));
    } else {
      _setPageToDisplay(new SplashScreen());
    }

    Future.wait([]).then((List answers) {});
  }

  _setPageToDisplay(Widget page) {
    setState(() {
      _pageToDisplay = page;
    });
  }
}
