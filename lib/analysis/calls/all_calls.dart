import 'dart:async';

import 'package:call_analyzer/analysis/services/analysis_service/analysis_service.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/models/call_log_info.dart';
import 'package:call_analyzer/models/life_event.dart';
import 'package:call_analyzer/widgets/call_icon.dart';
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
            ? Column(
                children: <Widget>[
                  _getFilters(),
                  Divider(),
                  Flexible(
                    child: _getCallsWithFilter(
                        snapshot.data.where(_shouldDisplayCallLog).toList()),
                  )
                ],
              )
            : Container(),
      ),
    );
  }

  _setup() {
    if (mounted) {
      _calls.add(_analysisService.callLogs);
    }
  }

  bool _isFilteringByContacts() {
    return _contactsToFilterBy.isNotEmpty;
  }

  // TODO: Do this async, create a function for this in AsyncFilter
  bool _shouldDisplayCallLog(CallLogInfo callLog) {
    bool show = _callTypesToFilterBy.contains(callLog.callType);
    if (show && _isFilteringByContacts()) {
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
          CallTile(callLog: calls[index]),
      itemCount: calls.length,
    );
  }

  Widget _getFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _getCallTypesToFilterByChips(),
          ),
          Row(
            children: _getFilterByContactChips(),
          ),
        ],
      ),
    );
  }

  List<Widget> _getFilterByContactChips() {
    return [
      Expanded(
        flex: 1,
        child: Text('Contacts: ${_contactsToFilterBy.isEmpty ? 'All' : ''}'),
      ),
      Expanded(
        flex: 4,
        child: Wrap(
          direction: Axis.horizontal,
          children: [
            ...[
              for (Contact contact in _contactsToFilterBy)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                  child: InputChip(
                      label: Text(
                        contact.displayName.split(' ').first,
                      ),
                      avatar: ContactImage(contact: contact, iconSize: 12.0),
                      onDeleted: () => _removeFromContactsToFilterBy(contact)),
                )
            ],
            IconButton(
              icon: Icon(FontAwesomeIcons.plusCircle),
              onPressed: () => ContactPickerDialog(context, contacts: _contacts)
                  .show()
                  .then((Contact contact) {
                if (contact != null) {
                  _addToContactsToFilterBy(contact);
                }
              }),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _getCallTypesToFilterByChips() {
    return [
      Text('Type:'),
      ...[
        for (CallType type in _allCallTypes)
          FilterChip(
            onSelected: (bool selected) =>
                _setCallTypesToFilterByForType(type, selected),
            label: CallIcon(callType: type),
            selected: _callTypesToFilterBy.contains(type),
          )
      ]
    ];
  }

  _setCallTypesToFilterByForType(CallType type, bool filter) {
    setState(() {
      if (filter) {
        _callTypesToFilterBy.add(type);
      } else {
        _callTypesToFilterBy.remove(type);
      }
    });
  }

  _removeFromContactsToFilterBy(Contact contact) {
    setState(() {
      _contactsToFilterBy.remove(contact);
    });
  }

  _addToContactsToFilterBy(Contact contact) {
    if (!_contactsToFilterBy.contains(contact)) {
      setState(() {
        _contactsToFilterBy.add(contact);
      });
    }
  }
}
