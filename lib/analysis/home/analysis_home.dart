import 'package:call_analyzer/analysis/home/contact_search.dart';
import 'package:call_analyzer/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnalysisHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
//          backgroundColor: Colors.transparent,
          appBar: AppBar(
//            backgroundColor: Colors.transparent,
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
                    showSearch(context: context, delegate: ContactSearch()),
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
    return PopupMenuButton<String>(
      tooltip: 'Settings',
      onSelected: (String option) => print('selected $option'),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'Settings',
          child: Text('Settings'),
        )
      ],
    );
  }
}
