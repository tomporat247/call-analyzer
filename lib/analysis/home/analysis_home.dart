import 'package:call_analyzer/analysis/contacts/contact_profile.dart';
import 'package:call_analyzer/analysis/home/contact_search.dart';
import 'package:call_analyzer/config.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnalysisHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                    icon: Tooltip(
                  message: 'Me',
                  child: Icon(FontAwesomeIcons.chartArea),
                )),
                Tab(
                    icon: Tooltip(
                  message: 'Top',
                  child: Icon(FontAwesomeIcons.medal),
                )),
                Tab(
                    icon: Tooltip(
                  message: 'Contacts',
                  child: Icon(FontAwesomeIcons.userFriends),
                )),
              ],
            ),
            title: Text(appTitle),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () =>
                    showSearch(context: context, delegate: ContactSearch())
                        .then((Contact contact) {
                  if (contact != null) {
                    _openContactPageFor(contact, context);
                  }
                }),
              ),
              _getPopupMenu(),
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              Icon(FontAwesomeIcons.chartArea),
              Icon(FontAwesomeIcons.medal),
              Icon(FontAwesomeIcons.userFriends)
            ],
          ),
        ));
  }

  Widget _getPopupMenu() {
    List<String> options = ['Settings'];

    return PopupMenuButton<String>(
      tooltip: 'Settings',
      onSelected: (String option) => print('selected $option'),
      itemBuilder: (BuildContext context) => [
        for (String option in options)
          PopupMenuItem<String>(
            value: option,
            child: Text(option),
          )
      ],
    );
  }

  _openContactPageFor(Contact contact, BuildContext context) {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => ContactProfile(contact)));
  }
}
