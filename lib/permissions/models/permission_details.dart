import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDetails {
  final PermissionGroup permissionGroup;
  final String name;
  final String description;
  final IconData icon;

  PermissionDetails(
      {@required this.permissionGroup,
      @required this.name,
      @required this.description,
      @required this.icon});
}
