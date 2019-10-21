import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CallIcon extends StatelessWidget {
  final CallType callType;

  CallIcon({@required this.callType});

  @override
  Widget build(BuildContext context) {
    return _getCallTypeIcon(callType);
  }

  Icon _getCallTypeIcon(CallType callType) {
    switch (callType) {
      case CallType.incoming:
      case CallType.answeredExternally:
        return Icon(Icons.call_received, color: Colors.green);
        break;
      case CallType.outgoing:
        return Icon(Icons.call_made, color: Colors.blue);
        break;
      case CallType.missed:
        return Icon(Icons.call_missed, color: Colors.red);
        break;
      case CallType.voiceMail:
        return Icon(Icons.voicemail, color: Colors.grey);
        break;
      case CallType.rejected:
        return Icon(FontAwesomeIcons.phoneSlash, color: Colors.black);
        break;
      default:
        return null;
    }
  }
}
