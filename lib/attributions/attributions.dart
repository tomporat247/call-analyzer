import 'package:call_analyzer/config.dart';
import 'package:call_analyzer/helper/helper.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Attributions extends StatelessWidget {
  List<ListTile> _attributionTiles;

  Attributions() {
    _attributionTiles = [
      _getAppIconAttribution(),
      _getTrophyAnimationAttribution(),
      _getCallAnimationAttribution(),
      _getPhoneAnimationAttribution(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Attributions'),
        ),
        body: ListView.separated(
          itemCount: _attributionTiles.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (BuildContext context, int index) =>
              _attributionTiles[index],
        ));
  }

  Widget _getAppIconAttribution() {
    return _getAttributionTile(
        title: RichText(
          text: TextSpan(children: [
            TextSpan(text: 'Icon made by '),
            _getTappableTextSpan(
                text: 'Freepik',
                onTap: () => launchURL('https://www.freepik.com/')),
            TextSpan(text: ' from '),
            _getTappableTextSpan(
                text: 'www.flaticon.com',
                onTap: () => launchURL('https://www.flaticon.com/home')),
          ]),
        ),
        trailing: CircleAvatar(
          child: Image(image: new AssetImage("assets/icons/app_icon.png")),
        ));
  }

  Widget _getPhoneAnimationAttribution() {
    return _getAttributionTile(
        title: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'A derivitive of The original flare animation made by '),
            _getTappableTextSpan(
                text: 'solomon babatunde',
                onTap: () => launchURL(
                    'https://www.2dimensions.com/a/solomon23/files/recent/all')),
            TextSpan(text: '\nUsed under '),
            _getTappableTextSpan(
                text: 'CC BY',
                onTap: () =>
                    launchURL('https://creativecommons.org/licenses/by/4.0/')),
            TextSpan(text: '\n'),
            _getOriginalLink(
                'https://www.2dimensions.com/a/solomon23/files/flare/new-file-9/preview')
          ]),
        ),
        trailing: _getFlareTrailing(
            fileName: 'assets/animations/phone_call.flr',
            animationName: 'call'));
  }

  Widget _getCallAnimationAttribution() {
    return _getAttributionTile(
        title: RichText(
          text: TextSpan(children: [
            TextSpan(text: 'Unmodified flare animation by '),
            _getTappableTextSpan(
                text: 'Mahen Gandhi',
                onTap: () => launchURL(
                    'https://www.2dimensions.com/a/imlegend19/files/recent/all')),
            TextSpan(text: '\nUsed under '),
            _getTappableTextSpan(
                text: 'CC BY',
                onTap: () =>
                    launchURL('https://creativecommons.org/licenses/by/4.0/')),
            TextSpan(text: '\n'),
            _getOriginalLink(
                'https://www.2dimensions.com/a/imlegend19/files/flare/phone/preview')
          ]),
        ),
        trailing: _getFlareTrailing(
            fileName: 'assets/animations/long_call_with.flr',
            animationName: 'Record2'));
  }

  Widget _getTrophyAnimationAttribution() {
    return _getAttributionTile(
        title: RichText(
          text: TextSpan(children: [
            TextSpan(text: 'Unmodified flare animation by '),
            _getTappableTextSpan(
                text: 'Gaston',
                onTap: () => launchURL(
                    'https://www.2dimensions.com/a/budindepan/files/recent/all')),
            TextSpan(text: '\nUsed Under '),
            _getTappableTextSpan(
                text: 'CC BY',
                onTap: () =>
                    launchURL('https://creativecommons.org/licenses/by/4.0/')),
            TextSpan(text: '\n'),
            _getOriginalLink(
                'https://www.2dimensions.com/a/budindepan/files/flare/trofeo/preview')
          ]),
        ),
        trailing: _getFlareTrailing(
            fileName: 'assets/animations/trophy.flr', animationName: 'trophy'));
  }

  TextSpan _getOriginalLink(String link) {
    return _getTappableTextSpan(text: 'Source', onTap: () => launchURL(link));
  }

  TextSpan _getTappableTextSpan(
      {String text,
      bool highlighted = true,
      bool italic = false,
      VoidCallback onTap}) {
    return TextSpan(
        text: text,
        style: TextStyle(
            fontWeight: highlighted ? FontWeight.bold : null,
            color: highlighted ? accentColor : null,
            fontStyle: italic ? FontStyle.italic : null),
        recognizer: TapGestureRecognizer()..onTap = onTap);
  }

  Widget _getFlareTrailing({String fileName, String animationName}) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: FlareActor(
        fileName,
        animation: animationName,
      ),
    );
  }

  Widget _getAttributionTile(
      {Widget title,
      String titleText,
      String subtitleText,
      Widget trailing,
      VoidCallback onTap}) {
    return ListTile(
      title: title == null ? Text(titleText) : title,
      subtitle: subtitleText != null ? Text(subtitleText) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
