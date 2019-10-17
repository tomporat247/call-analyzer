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
          appBar: AppBar(
            title: Text(appTitle),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(text: 'Me', icon: Icon(FontAwesomeIcons.chartArea)),
                Tab(text: 'Top', icon: Icon(FontAwesomeIcons.medal)),
                Tab(text: 'Contacts', icon: Icon(FontAwesomeIcons.userFriends)),
              ],
            ),
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
    // TODO: Allow re setting permissions from popup menu
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
