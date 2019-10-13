import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/permissions/models/permission_details.dart';
import 'package:call_analyzer/permissions/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequest extends StatefulWidget {
  final List<PermissionGroup> grantedPermissions;

  PermissionRequest({@required this.grantedPermissions});

  @override
  _PermissionRequestState createState() => _PermissionRequestState();
}

class _PermissionRequestState extends State<PermissionRequest> {
  final List<Color> backgroundColors = [
    Colors.blue[700],
    Colors.lightBlue[300]
  ];
  List<PermissionDetails> _permissions;
  Map<PermissionGroup, StepState> _permissionToStatus;
  int _currentStep;

  @override
  void initState() {
    _permissions =
        GetIt.instance<PermissionService>().requiredPermissionDetails;
    _currentStep = 0;
    _permissionToStatus = new Map();

    _permissions.forEach((permissionDetails) =>
        _permissionToStatus[permissionDetails.permission] =
            widget.grantedPermissions.contains(permissionDetails.permission)
                ? StepState.complete
                : StepState.indexed);

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
              child: Center(
                child: Text(
                  'Grant Call Analyzer the required permissions',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Stepper(
                  currentStep: _currentStep,
                  steps: [
                    for (PermissionDetails permissionDetails in _permissions)
                      Step(
                        title: Row(
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.only(right: defaultPadding),
                              child: new Icon(permissionDetails.icon),
                            ),
                            Text('${permissionDetails.name} Permission')
                          ],
                        ),
                        content: Text(permissionDetails.description),
                        state: _permissionToStatus[permissionDetails.permission]
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
