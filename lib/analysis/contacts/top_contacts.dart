import 'dart:async';

import 'package:call_analyzer/models/menu_text_option.dart';
import 'package:call_analyzer/models/sort_option.dart';
import 'package:call_analyzer/analysis/services/analysis_service.dart';
import 'package:call_analyzer/widgets/popup_menu_wrapper.dart';
import 'package:call_analyzer/widgets/slide_show.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'contact_slide.dart';

class TopContacts extends StatefulWidget {
  @override
  _TopContactsState createState() => _TopContactsState();
}

class _TopContactsState extends State<TopContacts> {
  final TextStyle filterPrefixStyle = TextStyle(color: Colors.white70);
  final TextStyle filterValueStyle = TextStyle(fontWeight: FontWeight.bold);
  SortOption _sortOption;
  AnalysisService _analysisService = GetIt.instance<AnalysisService>();
  StreamController<List<Contact>> _topContacts$;
  List<MenuTextOption> _menuSortOptions;

  @override
  initState() {
    _sortOption = SortOption.CALL_DURATION;
    _menuSortOptions = <MenuTextOption>[
      MenuTextOption(
        text: 'Call Duration',
        value: SortOption.CALL_DURATION,
        onPressed: () => _setSortOption(SortOption.CALL_DURATION),
      ),
      MenuTextOption(
        text: 'Call Amount',
        value: SortOption.CALL_AMOUNT,
        onPressed: () => _setSortOption(SortOption.CALL_AMOUNT),
      ),
    ];
    _topContacts$ = StreamController<List<Contact>>();
    _fetchContacts();
    super.initState();
  }

  @override
  dispose() {
    _topContacts$?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Contact>>(
      stream: _topContacts$.stream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[_getFilterOptions(context), Divider()],
                ),
              ),
              Expanded(
                flex: 7,
                child: SlideShow([
                  for (Contact contact in snapshot.data) ContactSlide(contact)
                ]),
              )
            ],
          );
        }
        return Container();
      },
    );
  }

  _fetchContacts() {
    _analysisService
        .getTopContacts(sortOption: _sortOption)
        .then((List<Contact> contacts) => _topContacts$.sink.add(contacts));
  }

  Widget _getFilterOptions(BuildContext context) {
    return PopupMenuWrapper(
      options: _menuSortOptions,
      child: _getFilterFor(RichText(
        text: TextSpan(children: [
          TextSpan(text: 'Sort By: ', style: filterPrefixStyle),
          TextSpan(
              text: _menuSortOptions
                  .firstWhere(
                      (MenuTextOption option) => option.value == _sortOption)
                  .data,
              style: filterValueStyle),
        ]),
      )),
    );
  }

  Widget _getFilterFor(RichText richText) {
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      richText,
      Icon(Icons.arrow_drop_down),
    ]);
  }

  _setSortOption(SortOption option) {
    setState(() {
      _sortOption = option;
      _fetchContacts();
    });
  }
}
