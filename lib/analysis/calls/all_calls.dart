import 'package:call_analyzer/models/life_event.dart';
import 'package:flutter/material.dart';

class AllCalls extends StatefulWidget {
  final Stream<LifeEvent> _lifeEvent$;

  AllCalls(this._lifeEvent$);

  @override
  _AllCallsState createState() => _AllCallsState();
}

class _AllCallsState extends State<AllCalls> {
  @override
  void initState() {
    _setup();
    widget._lifeEvent$.takeWhile((e) => mounted).listen((LifeEvent event) {
      if (event == LifeEvent.RELOAD) {
        _setup();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text('c');
  }

  _setup() {}
}
