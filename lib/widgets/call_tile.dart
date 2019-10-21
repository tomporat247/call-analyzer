import 'package:call_analyzer/analysis/contacts/contact_tile.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'call_icon.dart';

class CallTile extends StatelessWidget {
  final CallLogInfo callLog;

  CallTile({@required this.callLog});

  @override
  Widget build(BuildContext context) {
    String dateTime = '${stringifyDateTime(callLog.dateTime, withTime: true)} '
        '(${stringifyDuration(callLog.duration)})';
    Widget callIcon = CallIcon(callType: callLog.callType);
    return callLog.contact != null
        ? ContactTile(
            callLog.contact,
            trailing: callIcon,
            subtitleText: dateTime,
          )
        : ListTile(
            leading: CircleAvatar(
              child: Icon(FontAwesomeIcons.userSecret),
              backgroundColor: Colors.grey,
            ),
            trailing: callIcon,
            title: Text(callLog.number ?? callLog.formattedNumber),
            subtitle: Text(dateTime),
          );
  }
}
