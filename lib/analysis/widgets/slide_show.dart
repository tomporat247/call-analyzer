import 'package:call_analyzer/config.dart';
import 'package:flutter/material.dart';

class SlideShow extends StatefulWidget {
  final List<Widget> slides;
  final bool withOffset;
  final bool withAppGradient;
  final void Function(int previous, int curr) onPageSwitch;

  SlideShow(this.slides,
      {this.withOffset = true, this.withAppGradient = true, this.onPageSwitch});

  @override
  _SlideShowState createState() => _SlideShowState();
}

class _SlideShowState extends State<SlideShow> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final double _slideBorderRadius = 30.0;
  int _currentPageIndex;

  @override
  initState() {
    _currentPageIndex = 0;
    _listenToPageChanges();
    super.initState();
  }

  @override
  dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.slides.length,
      itemBuilder: (BuildContext context, int pageIndex) {
        bool active = _currentPageIndex == pageIndex;
        return _buildSlide(widget.slides[pageIndex], active);
      },
    );
  }

  _listenToPageChanges() {
    _pageController.addListener(() {
      int next = _pageController.page.round();
      if (_currentPageIndex != next) {
        setState(() {
          int prev = _currentPageIndex;
          _currentPageIndex = next;
          if (widget.onPageSwitch != null) {
            widget.onPageSwitch(prev, next);
          }
        });
      }
    });
  }

  Widget _buildSlide(Widget slide, bool active) {
    final double blur = active ? 30 : 0;
    final double offset = active && widget.withOffset ? 20 : 0;
    final double sides = active ? 50 : 80;

    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(left: sides, right: sides, bottom: 30),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_slideBorderRadius),
          gradient: widget.withAppGradient ? appGradient : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black87,
                blurRadius: blur,
                offset: Offset(offset, offset))
          ]),
      child: slide,
    );
  }
}
