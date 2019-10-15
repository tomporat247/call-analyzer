import 'package:call_analyzer/analysis/home/contact_search.dart';
import 'package:call_analyzer/config.dart';
import 'package:flutter/material.dart';

class AnalysisHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
//          backgroundColor: Colors.transparent,
          appBar: AppBar(
            bottom: TabBar(
              tabs: <Widget>[
                Tab(icon: Icon(Icons.ac_unit)),
                Tab(icon: Icon(Icons.map)),
                Tab(icon: Icon(Icons.contacts)),
              ],
            ),
            title: Text(appTitle),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () =>
                    showSearch(context: context, delegate: ContactSearch()),
              )
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              Icon(Icons.ac_unit),
              Icon(Icons.map),
              Icon(Icons.contacts)
            ],
          ),
        ));
  }
}
