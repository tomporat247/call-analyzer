import 'package:call_analyzer/analysis/services/analysis_service.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

class ContactSearch extends SearchDelegate<String> {
  AnalysisService _analysisService;
  List<Contact> _topContacts;

  ContactSearch() {
    _analysisService = GetIt.instance<AnalysisService>();
    _topContacts = new List<Contact>();
    _analysisService
        .getTopContacts(_analysisService.topContactsAmount)
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
    // TODO: implement buildResults
    return null;
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
          leading: _getContactImage(contact),
          title: RichText(
            text: TextSpan(style: TextStyle(color: Colors.black), children: [
              TextSpan(text: contact.displayName.substring(0, boldStartIndex)),
              TextSpan(
                  text: contact.displayName
                      .substring(boldStartIndex, boldEndIndex),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: contact.displayName.substring(boldEndIndex)),
            ]),
          ),
        );
      },
      itemCount: suggestedContacts.length,
    );
  }

  Widget _getContactImage(Contact contact) {
    return contact.avatar == null
        ? Icon(FontAwesomeIcons.user)
        : FutureBuilder(
            future: _analysisService.getContactWithImage(contact),
            builder: (BuildContext context, AsyncSnapshot<Contact> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var avatar = snapshot.data.avatar;
                return avatar == null
                    ? Icon(FontAwesomeIcons.user)
                    : CircleAvatar(
                        backgroundImage: MemoryImage(avatar),
                      );
              } else {
                return CircularProgressIndicator();
              }
            },
          );
  }
}
