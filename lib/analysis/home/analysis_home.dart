import 'dart:async';

import 'package:call_analyzer/analysis/calls/all_calls.dart';
import 'package:call_analyzer/analysis/contacts/contact_profile.dart';
import 'package:call_analyzer/analysis/contacts/all_contacts.dart';
import 'package:call_analyzer/analysis/general_details/general_details.dart';
import 'package:call_analyzer/analysis/home/contact_search.dart';
import 'package:call_analyzer/analysis/services/analysis_service/analysis_service.dart';
import 'package:call_analyzer/analysis/top/top_accolades.dart';
import 'package:call_analyzer/attributions/attributions.dart';
import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:call_analyzer/models/life_event.dart';
import 'package:call_analyzer/permissions/permission_request.dart';
import 'package:call_analyzer/services/permission_service.dart';
import 'package:call_analyzer/widgets/banner_ad_padder.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class AnalysisHome extends StatefulWidget {
  @override
  _AnalysisHomeState createState() => _AnalysisHomeState();
}

class _AnalysisHomeState extends State<AnalysisHome> {
  AnalysisService _analysisService = GetIt.instance<AnalysisService>();
  PermissionService _permissionService = GetIt.instance<PermissionService>();
  StreamController<LifeEvent> _lifeEvent$;

  @override
  initState() {
    _lifeEvent$ = new StreamController.broadcast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 1,
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(appTitle),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(text: 'General', icon: Icon(FontAwesomeIcons.chartPie)),
                Tab(text: 'Top', icon: Icon(FontAwesomeIcons.medal)),
                Tab(text: 'Contacts', icon: Icon(FontAwesomeIcons.userFriends)),
                Tab(text: 'Calls', icon: Icon(FontAwesomeIcons.history)),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () =>
                    showSearch(context: context, delegate: ContactSearch())
                        .then((Contact contact) {
                  if (contact != null) {
                    _openContactPageFor(contact);
                  }
                }),
              ),
              _getPopupMenu(),
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              GeneralDetails(_lifeEvent$.stream),
              TopAccolades(_lifeEvent$.stream),
              AllContacts(_lifeEvent$.stream),
              AllCalls(_lifeEvent$.stream)
            ],
          ),
          floatingActionButton: _getDateFilter(),
        ));
  }

  Widget _getDateFilter() {
    return SpeedDial(
      overlayColor: Colors.black,
      closeManually: false,
      curve: Curves.bounceIn,
      tooltip: 'Filter',
      elevation: 8.0,
      child: Icon(
        FontAwesomeIcons.filter,
        color: _analysisService.isFilteringByDate ? Colors.deepPurple : null,
      ),
      children: <SpeedDialChild>[
        _getSpeedDialChildWrapper(
            iconData: FontAwesomeIcons.calendarAlt,
            labelText:
                'Filter To: ${stringifyDateTime(_analysisService.filterTo)}',
            onTap: () {
              _getDateFromUser(
                      firstDate: _analysisService.filterFrom,
                      lastDate: DateTime.now())
                  .then((DateTime to) {
                if (to != null) {
                  _filterByDate(
                      to: DateTime(to.year, to.month, to.day, 23, 59, 59));
                }
              });
            }),
        _getSpeedDialChildWrapper(
            iconData: FontAwesomeIcons.calendarAlt,
            labelText:
                'Filter From: ${stringifyDateTime(_analysisService.filterFrom)}',
            onTap: () {
              _getDateFromUser(
                      firstDate: _analysisService.getFirstCallDate(
                          firstFromAllTime: true),
                      lastDate: _analysisService.filterTo)
                  .then((DateTime from) {
                if (from != null) {
                  _filterByDate(
                      from: DateTime(from.year, from.month, from.day));
                }
              });
            }),
        _getSpeedDialChildWrapper(
            iconData: FontAwesomeIcons.undo,
            labelText: 'Reset Filters',
            onTap: () {
              _filterByDate(
                  from:
                      _analysisService.getFirstCallDate(firstFromAllTime: true),
                  to: DateTime.now());
            }),
      ],
    );
  }

  _filterByDate({DateTime from, DateTime to}) async {
    await _analysisService.filterByDate(from: from, to: to);
    setState(() {
      _lifeEvent$.add(LifeEvent.RELOAD);
    });
  }

  SpeedDialChild _getSpeedDialChildWrapper(
      {VoidCallback onTap, IconData iconData, String labelText}) {
    return SpeedDialChild(
        child: Icon(iconData),
        labelWidget: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.grey[700],
          ),
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text(labelText),
          ),
        ),
        labelBackgroundColor: Colors.black,
        onTap: onTap);
  }

  Future<DateTime> _getDateFromUser(
      {@required DateTime firstDate, @required DateTime lastDate}) {
    DateTime now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: now.isAfter(lastDate) ? lastDate : now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: getAppTheme(context),
          child: child,
        );
      },
    );
  }

  Widget _getPopupMenu() {
    const String permissionsOption = 'Permissions';
    const String attributionsOption = 'Attributions';
    List<String> options = [permissionsOption, attributionsOption];

    return Builder(
      builder: (BuildContext context) => PopupMenuButton<String>(
        onSelected: (String option) async {
          switch (option) {
            case permissionsOption:
              if (!(await _permissionService.hasOptionalPermissions())) {
                List<PermissionGroup> grantedPermissions =
                    await _permissionService.getGrantedPermissions();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BannerAdPadder(PermissionRequest(
                        grantedPermissions: grantedPermissions))));
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'All permissions granted (Contacts, Call logs & Storage)'),
                ));
              }
              break;
            case attributionsOption:
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BannerAdPadder(Attributions())));
              break;
            default:
              break;
          }
        },
        itemBuilder: (BuildContext context) => [
          for (String option in options)
            PopupMenuItem<String>(
              value: option,
              child: Text(option),
            )
        ],
      ),
    );
  }

  _openContactPageFor(Contact contact) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ContactProfile(contact)));
  }
}
