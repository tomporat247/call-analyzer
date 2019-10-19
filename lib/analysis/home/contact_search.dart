import 'package:call_analyzer/analysis/services/analysis_service.dart';
import 'package:call_analyzer/widgets/contact_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ContactSearch extends SearchDelegate<Contact> {
  AnalysisService _analysisService;
  List<Contact> _topContacts;
  final TextStyle contactNameTextStyle =
      TextStyle(color: Colors.white70.withOpacity(0.9));

  ContactSearch() {
    _analysisService = GetIt.instance<AnalysisService>();
    _topContacts = new List<Contact>();
    _analysisService
        .getTopContacts(amount: 10)
        .then((List<Contact> topContacts) => _topContacts = topContacts);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
        inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: theme.primaryTextTheme.title.color)),
        primaryColor: theme.primaryColor,
        primaryIconTheme: theme.primaryIconTheme,
        primaryColorBrightness: theme.primaryColorBrightness,
        primaryTextTheme: theme.primaryTextTheme,
        textTheme: theme.textTheme.copyWith(
            title: theme.textTheme.title
                .copyWith(color: theme.primaryTextTheme.title.color)));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Contact> suggestedContacts = query.isEmpty
        ? _topContacts
        : _analysisService.contacts
            .where((Contact contact) =>
                contact.displayName.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        Contact contact = suggestedContacts[index];
        int boldStartIndex =
            contact.displayName.toLowerCase().indexOf(query.toLowerCase());
        int boldEndIndex = boldStartIndex + query.length;

        return ListTile(
          onTap: () => close(context, contact),
          leading: ContactImage(contact: contact),
          title: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: contact.displayName.substring(0, boldStartIndex),
                  style: contactNameTextStyle),
              TextSpan(
                  text: contact.displayName
                      .substring(boldStartIndex, boldEndIndex),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              TextSpan(
                  text: contact.displayName.substring(boldEndIndex),
                  style: contactNameTextStyle),
            ]),
          ),
        );
      },
      itemCount: suggestedContacts.length,
    );
  }
}
