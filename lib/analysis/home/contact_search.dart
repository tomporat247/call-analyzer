import 'package:call_analyzer/analysis/services/analysis_service.dart';
import 'package:call_analyzer/analysis/widgets/contact_image.dart';
import 'package:call_analyzer/config.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// TODO: Search string color is white and can't be seen

class ContactSearch extends SearchDelegate<Contact> {
  AnalysisService _analysisService;
  List<Contact> _topContacts;

  ContactSearch() {
    _analysisService = GetIt.instance<AnalysisService>();
    _topContacts = new List<Contact>();
    _analysisService
        .getTopContacts()
        .then((List<Contact> topContacts) => _topContacts = topContacts);
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
          leading: ContactImage(contact),
          title: RichText(
            text: TextSpan(children: [
              TextSpan(text: contact.displayName.substring(0, boldStartIndex)),
              TextSpan(
                  text: contact.displayName
                      .substring(boldStartIndex, boldEndIndex),
                  style: TextStyle(fontWeight: FontWeight.bold, color: getAppTheme(context).accentColor)),
              TextSpan(text: contact.displayName.substring(boldEndIndex)),
            ]),
          ),
        );
      },
      itemCount: suggestedContacts.length,
    );
  }
}
