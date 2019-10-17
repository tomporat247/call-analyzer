import 'package:call_analyzer/models/menu_text_option.dart';
import 'package:flutter/material.dart';

class PopupMenuWrapper extends StatelessWidget {
  final List<MenuTextOption> options;
  final String tooltip;
  final Icon icon;
  final Widget child;

  PopupMenuWrapper(
      {@required this.options, this.tooltip, this.icon, this.child});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuTextOption>(
      tooltip: tooltip,
      icon: icon,
      child: child,
      onSelected: (MenuTextOption option) => option.onPressed(),
      itemBuilder: (BuildContext context) {
        return options
            .map((MenuTextOption option) => PopupMenuItem<MenuTextOption>(
                  value: option,
                  child: option,
                ))
            .toList();
      },
    );
  }
}
