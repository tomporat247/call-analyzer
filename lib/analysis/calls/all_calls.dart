import 'dart:async';

import 'package:call_analyzer/analysis/services/analysis_service/analysis_service.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:call_analyzer/models/life_event.dart';
import 'package:call_analyzer/widgets/call_tile.dart';
import 'package:call_analyzer/widgets/contact_image.dart';
import 'package:call_analyzer/widgets/dialogs/contact_picker_dialog.dart';
import 'package:call_log/call_log.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

class AllCalls extends StatefulWidget {
  final Stream<LifeEvent> _lifeEvent$;

  AllCalls(this._lifeEvent$);

  @override
  _AllCallsState createState() => _AllCallsState();
}

class _AllCallsState extends State<AllCalls> {
  AnalysisService _analysisService = GetIt.instance<AnalysisService>();
  StreamController<List<CallLogInfo>> _calls;
  List<Contact> _contacts;
  bool _filterByContacts = false;
  List<Contact> _contactsToFilterBy;
  final List<CallType> _allCallTypes = [
    CallType.incoming,
    CallType.outgoing,
    CallType.missed,
    CallType.rejected
  ];
  List<CallType> _callTypesToFilterBy;

  @override
  void initState() {
    _calls = StreamController<List<CallLogInfo>>();
    _contacts = _analysisService.contacts;
    _callTypesToFilterBy = [..._allCallTypes];
    _contactsToFilterBy = new List<Contact>();
    _setup();
    widget._lifeEvent$.takeWhile((e) => mounted).listen((LifeEvent event) {
      if (event == LifeEvent.RELOAD) {
        _setup();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _calls?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _calls.stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<CallLogInfo>> snapshot) =>
              AnimatedSwitcher(
        duration: fastSwitchDuration,
        child: (snapshot.hasData && snapshot.data != null)
            ? _getCallsWithFilter(
                snapshot.data.where(_shouldDisplayCallLog).toList())
            : Container(),
      ),
    );
  }

  _setup() {
    if (mounted) {
      _calls.add(_analysisService.callLogs);
    }
  }

  // TODO: Do this async, create a function for this in AsyncFilter
  bool _shouldDisplayCallLog(CallLogInfo callLog) {
    bool show = _callTypesToFilterBy.contains(callLog.callType);
    if (show && _filterByContacts) {
      show = callLog.contact != null &&
          _contactsToFilterBy
              .map((Contact c) => c.identifier)
              .contains(callLog.contact.identifier);
    }
    return show;
  }

  Widget _getCallsWithFilter(List<CallLogInfo> calls) {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      itemBuilder: (BuildContext context, int index) =>
          index == 0 ? _getFilters() : CallTile(callLog: calls[index - 1]),
      itemCount: calls.length + 1,
    );
  }

  Widget _getFilters() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.only(left: defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _getCallTypesToFilterByChips(),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getFilterByContactChips(),
          ),
        ),
      ],
    );
  }

  List<Widget> _getFilterByContactChips() {
    return [
      Row(
        children: <Widget>[
          Checkbox(
            onChanged: (bool isChecked) {
              setState(() {
                _filterByContacts = isChecked;
              });
            },
            value: _filterByContacts,
          ),
          Text('Filter By Contacts'),
          IconButton(
            icon: Icon(FontAwesomeIcons.plusCircle),
            onPressed: !_filterByContacts
                ? null
                : () {
                    ContactPickerDialog(context,
                            allContacts: _contacts,
                            selectedContacts: _contactsToFilterBy)
                        .show()
                        .then((List<Contact> selectedContacts) {
                      setState(() {
                        _contactsToFilterBy = selectedContacts;
                      });
                    });
                  },
          ),
        ],
      ),
      Wrap(
        direction: Axis.horizontal,
        children: <Widget>[
          for (Contact contact in _contactsToFilterBy)
            InputChip(
                label: Text(
                  contact.displayName.split(' ').first,
                ),
                avatar: ContactImage(contact: contact, iconSize: 12.0),
                onDeleted: () {
                  setState(() {
                    _contactsToFilterBy.remove(contact);
                  });
                })
        ],
      )
    ];
  }

  List<Widget> _getCallTypesToFilterByChips() {
    return [
      for (CallType type in _allCallTypes)
        FilterChip(
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _callTypesToFilterBy.add(type);
              } else {
                _callTypesToFilterBy.remove(type);
              }
            });
          },
          label: Text(_getCallTypeName(type)),
          selected: _callTypesToFilterBy.contains(type),
        )
    ];
  }

  String _getCallTypeName(CallType callType) {
    switch (callType) {
      case CallType.incoming:
      case CallType.answeredExternally:
        return 'Incoming';
        break;
      case CallType.outgoing:
        return 'Outgoing';
        break;
      case CallType.missed:
        return 'Missed';
        break;
      // TODO: Voicemail doesn't work
//      case CallType.voiceMail:
//        break;
      case CallType.rejected:
        return 'Rejected';
        break;
      default:
        return null;
    }
  }
}
