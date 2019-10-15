import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/permissions/models/permission_details.dart';
import 'package:call_analyzer/permissions/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequest extends StatefulWidget {
  final List<PermissionGroup> grantedPermissions;
  final Function onAllPermissionsGranted;

  PermissionRequest(
      {@required this.grantedPermissions, this.onAllPermissionsGranted});

  @override
  _PermissionRequestState createState() => _PermissionRequestState();
}

class _PermissionRequestState extends State<PermissionRequest> {
  PermissionService _permissionService;
  List<PermissionDetails> _permissions;
  int _currentStep;
  Set<PermissionGroup> _grantedPermissions;

  @override
  void initState() {
    _grantedPermissions = widget.grantedPermissions.toSet();
    _permissionService = GetIt.instance<PermissionService>();
    _setupPermissions();
    _currentStep = _grantedPermissions.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Grant Required Permissions',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 3.0,
                      color: Colors.cyan[900],
                      offset: Offset(-4.0, 4.0),
                    ),
                  ]),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * defaultPadding),
            child: LiquidLinearProgressIndicator(
              value: _grantedPermissions.length / _permissions.length,
              backgroundColor: Colors.white.withAlpha((0.1 * 255).round()),
              borderColor: Colors.transparent,
              borderWidth: 0,
              borderRadius: 16.0,
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: _getStepper(),
        ),
      ],
    );
  }

  _setupPermissions() {
    _permissions = _permissionService.requiredPermissionDetails;
    _grantedPermissions.forEach((permission) {
      PermissionDetails permissionDetails =
          _permissions.firstWhere((perm) => perm.permissionGroup == permission);
      _permissions.remove(permissionDetails);
      _permissions.insert(0, permissionDetails);
    });
  }

  Stepper _getStepper() {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: () =>
          _requestPermission(_permissions[_currentStep].permissionGroup),
      onStepTapped: (index) => _updateCurrentStep(index),
      controlsBuilder: (BuildContext context,
              {VoidCallback onStepContinue, VoidCallback onStepCancel}) =>
          Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 2 * defaultPadding),
            child: RaisedButton.icon(
                onPressed: onStepContinue,
                icon: Icon(FontAwesomeIcons.checkCircle),
                label: Text('Allow')),
          )
        ],
      ),
      steps: [
        for (PermissionDetails permissionDetails in _permissions)
          Step(
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: defaultPadding),
                    child: Icon(
                      permissionDetails.icon,
                      color: Colors.grey[200],
                    ),
                  ),
                  Text('${permissionDetails.name} Permission')
                ],
              ),
              content: Text(permissionDetails.description),
              state: _grantedPermissions
                      .contains(permissionDetails.permissionGroup)
                  ? StepState.complete
                  : StepState.indexed)
      ],
    );
  }

  _requestPermission(PermissionGroup permissionGroup) {
    _permissionService
        .requestPermission(permissionGroup)
        .then((permissionGranted) {
      if (permissionGranted) {
        _addToGrantedPermissions(permissionGroup);
        _updateCurrentStep(_currentStep + 1);
      }
    });
  }

  _updateCurrentStep(int stepIndex) {
    setState(() {
      _currentStep = stepIndex % _permissions.length;
    });
  }

  _addToGrantedPermissions(PermissionGroup permissionGroup) {
    setState(() {
      _grantedPermissions.add(permissionGroup);
      if (_grantedPermissions.length == _permissions.length) {
        widget.onAllPermissionsGranted();
      }
    });
  }
}
