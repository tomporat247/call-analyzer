import 'package:background_fetch/background_fetch.dart';
import 'package:call_analyzer/analysis/home/analysis_home.dart';
import 'package:call_analyzer/call_log/services/call_log_parser_service.dart';
import 'package:call_analyzer/call_log/services/call_log_service.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/contacts/services/contact_service.dart';
import 'package:call_analyzer/permissions/permission_request.dart';
import 'package:call_analyzer/permissions/services/permission_service.dart';
import 'package:call_analyzer/splash_screen/splash_screen.dart';
import 'package:call_analyzer/storage/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'analysis/services/analysis_service/analysis_service.dart';

_headlessUpdateCallLogs() async {
  await CallLogService(
          StorageService(), CallLogParserService(), PermissionService())
      .getUpdatedCallLogs();

  BackgroundFetch.finish();
}

void main() {
  _registerServices();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
    BackgroundFetch.registerHeadlessTask(_headlessUpdateCallLogs);
  });
}

_registerServices() {
  GetIt.instance.registerSingleton(PermissionService());
  GetIt.instance.registerSingleton(AnalysisService(ContactService()));
}

// TODO: Extract the life event stream to a global scope, if filter is not active => recall the analysis service init and the RELOAD life event

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
    _determineInitialPageToDisplay();
    _setupBackgroundFetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: getAppTheme(context),
      home: Material(
        child: AnimatedSwitcher(
          child: _pageToDisplay,
          duration: normalSwitchDuration,
          switchInCurve: Curves.easeInOut,
        ),
      ),
    );
  }

  _setupBackgroundFetch() async {
    BackgroundFetch.configure(
            BackgroundFetchConfig(
                minimumFetchInterval: backgroundFetchInterval.inMinutes,
                enableHeadless: true,
                stopOnTerminate: false,
                startOnBoot: true,
                requiresBatteryNotLow: false,
                requiresCharging: false,
                requiresStorageNotLow: false,
                requiresDeviceIdle: false,
                requiredNetworkType: BackgroundFetchConfig.NETWORK_TYPE_NONE),
            _onNonHeadlessBackgroundFetch)
        .then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
  }

  _onNonHeadlessBackgroundFetch() {
    _headlessUpdateCallLogs();
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
      CallLogService(
              StorageService(), CallLogParserService(), _permissionService)
          .getUpdatedCallLogs()
    ]);
    await GetIt.instance<AnalysisService>().init(answers[0], answers[1]);
    _setPageToDisplay(AnalysisHome());
  }

  _setPageToDisplay(Widget page) {
    setState(() {
      _pageToDisplay = page;
    });
  }
}
