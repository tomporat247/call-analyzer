import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/permissions/models/permission_details.dart';
import 'package:call_analyzer/permissions/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  final List<Color> backgroundColors = [
    Colors.blue[700],
    Colors.lightBlue[300]
  ];
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
    return new Material(
      child: new Container(
        decoration: new BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundColors,
          ),
        ),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 4 * defaultPadding, top: 4 * defaultPadding),
                  child: Text(
                    'Grant Required\nPermissions',
                    style: TextStyle(
                      fontSize: 34,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: _getStepper(),
              ),
            ),
          ],
        ),
      ),
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
      steps: [
        for (PermissionDetails permissionDetails in _permissions)
          Step(
              title: Row(
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(right: defaultPadding),
                    child: new Icon(
                      permissionDetails.icon,
                      color: Colors.grey[200],
                    ),
                  ),
                  Text('${permissionDetails.name} Permission')
                ],
              ),
              content: Text(permissionDetails.description),
              state: _grantedPermissions.contains(permissionDetails.permissionGroup)
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
