import 'package:call_analyzer/permissions/models/permission_details.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionHandler _permissionHandler;
  List<PermissionGroup> _requiredPermissions;

  // TODO: Make the storage permission optional

  List<PermissionDetails> get requiredPermissionDetails => [
        PermissionDetails(
            permissionGroup: PermissionGroup.phone,
            icon: FontAwesomeIcons.phoneAlt,
            name: 'Call Logs',
            description:
                'Allow this app to access device call logs to view and analuze your calls'),
        PermissionDetails(
            permissionGroup: PermissionGroup.contacts,
            name: 'Contacts',
            icon: FontAwesomeIcons.addressBook,
            description:
                'Allow this app to access your contacts to view and compare your calls with them'),
        PermissionDetails(
            permissionGroup: PermissionGroup.storage,
            icon: FontAwesomeIcons.archive,
            name: 'Storage',
            description:
                'Allow this app to access device storage to store all call logs and quickly load them'),
      ];

  PermissionService() {
    _permissionHandler = PermissionHandler();
    _requiredPermissions = [
      PermissionGroup.phone,
      PermissionGroup.contacts,
      PermissionGroup.storage,
    ];
  }

  Future<bool> hasRequiredPermissions() async {
    for (PermissionGroup permission in _requiredPermissions) {
      if (!(await hasPermission(permission))) {
        return false;
      }
    }
    return true;
  }

  Future<List<PermissionGroup>> getGrantedPermissions() async {
    List<PermissionGroup> grantedPermissions = new List();
    for (PermissionGroup permission in _requiredPermissions) {
      if (await hasPermission(permission)) {
        grantedPermissions.add(permission);
      }
    }
    return grantedPermissions;
  }

  Future<bool> hasPermission(PermissionGroup permission) async {
    return (await _permissionHandler.checkPermissionStatus(permission)) ==
        PermissionStatus.granted;
  }

  Future<bool> requestPermission(PermissionGroup permission) async {
    return (await _permissionHandler
            .requestPermissions([permission]))[permission] ==
        PermissionStatus.granted;
  }
}
