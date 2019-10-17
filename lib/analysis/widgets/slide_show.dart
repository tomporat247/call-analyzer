import 'package:flutter/material.dart';

class SlideShow extends StatefulWidget {
  final List<Widget> slides;

  SlideShow(this.slides);

  @override
  _SlideShowState createState() => _SlideShowState();
}

class _SlideShowState extends State<SlideShow> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final double _slideBorderRadius = 20.0;
  int _currentPageIndex;

  @override
  initState() {
    _currentPageIndex = 0;
    _listenToPageChanges();
    super.initState();
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
          _currentPageIndex = next;
        });
      }
    });
  }

  Widget _buildSlide(Widget slide, bool active) {
    final double blur = active ? 30 : 0;
    final double offset = active ? 20 : 0;
    final double sides = active ? 60 : 100;

    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(left: sides, right: sides, bottom: 50),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_slideBorderRadius),
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
