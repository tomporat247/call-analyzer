import 'package:call_analyzer/analysis/home/analysis_home.dart';
import 'package:call_analyzer/analysis/home/services/analysis_service.dart';
import 'package:call_analyzer/call_log/services/call_log_parser_service.dart';
import 'package:call_analyzer/call_log/services/call_log_service.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/contacts/services/contact_service.dart';
import 'package:call_analyzer/permissions/pages/permission_request.dart';
import 'package:call_analyzer/permissions/services/permission_service.dart';
import 'package:call_analyzer/splash_screen/splash_screen.dart';
import 'package:call_analyzer/storage/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
  _registerServices();
  runApp(MyApp());
}

_registerServices() {
  GetIt.instance.registerSingleton(PermissionService());
  GetIt.instance.registerSingleton(AnalysisService());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Color> backgroundColors = [Color(0xff1a9c91), Color(0xff0c4661)];
  Widget _pageToDisplay;
  PermissionService _permissionService = GetIt.instance<PermissionService>();

  @override
  void initState() {
    _pageToDisplay = Container();
    _determineInitialPageToDisplay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: getAppTheme(context),
      home: Material(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: backgroundColors,
            ),
          ),
          child: AnimatedSwitcher(
            child: _pageToDisplay,
            duration: Duration(seconds: 1),
            switchInCurve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }

  _determineInitialPageToDisplay() async {
    if (await _permissionService.hasRequiredPermissions()) {
      _loadCallLogsAndContacts();
    } else {
      _requestPermissions();
    }
  }

  _requestPermissions() async {
    _setPageToDisplay(PermissionRequest(
      grantedPermissions: await _permissionService.getGrantedPermissions(),
      onAllPermissionsGranted: () => _loadCallLogsAndContacts(),
    ));
  }

  _loadCallLogsAndContacts() async {
    _setPageToDisplay(SplashScreen());
    List answers = await Future.wait([
      ContactService().getContacts(),
      CallLogService(StorageService(), CallLogParserService())
          .getUpdatedCallLogs()
    ]);
    GetIt.instance<AnalysisService>().init(answers[0], answers[1]);
    _setPageToDisplay(AnalysisHome());
  }

  _setPageToDisplay(Widget page) {
    setState(() {
      _pageToDisplay = page;
    });
  }
}
