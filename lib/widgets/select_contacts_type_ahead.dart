import 'package:call_analyzer/analysis/contacts/contact_tile.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SelectContactsTypeAhead extends TypeAheadField {
  SelectContactsTypeAhead({
    @required BuildContext context,
    @required List<Contact> contacts,
    @required void onSelected(contact),
    TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    TextStyle style,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    InputDecoration decoration,
    ValueChanged onSubmitted,
    FocusNode focusNode,
    bool autoFocus = false,
  }) : super(
          textFieldConfiguration: TextFieldConfiguration<String>(
            autofocus: autoFocus,
            decoration: decoration,
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: style,
            onSubmitted: onSubmitted,
            focusNode: focusNode,
          ),
          suggestionsBoxDecoration: new SuggestionsBoxDecoration(
            color: Colors.blueGrey[900],
          ),
          suggestionsCallback: (String pattern) {
            if (pattern.isEmpty) {
              return [];
            }
            return contacts
                .where((Contact contact) => contact.displayName
                    .toLowerCase()
                    .contains(pattern.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, suggestion) {
            return new ContactTile(suggestion, tapToOpenContactProfile: false);
          },
          noItemsFoundBuilder: (BuildContext context) => new Container(
            height: 0.0,
            width: 0.0,
          ),
          onSuggestionSelected: onSelected,
        );
}
