import 'package:call_analyzer/widgets/slide.dart';
import 'package:flutter/material.dart';

class SlideShow extends StatefulWidget {
  final List<Slide> slides;
  final bool withOffset;
  final void Function(int previous, int curr) onPageSwitch;
  final bool animate;

  SlideShow(
      {@required this.slides,
      this.animate = true,
      this.withOffset = true,
      this.onPageSwitch});

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

  Widget _buildSlide(Slide slide, bool active) {
    final double blur = active ? 30 : 0;
    final double offset = active && widget.withOffset ? 20 : 0;
    final double sides = active ? 50 : 80;
    final margin = EdgeInsets.only(left: sides, right: sides, bottom: 30);

    return widget.animate
        ? AnimatedContainer(
            duration: Duration(seconds: 1),
            curve: Curves.easeOutQuint,
            margin: margin,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_slideBorderRadius),
                gradient: slide.gradient,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black87,
                      blurRadius: blur,
                      offset: Offset(offset, offset))
                ]),
            child: slide,
          )
        : Container(
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
            decoration: BoxDecoration(
              gradient: slide.gradient,
              borderRadius: BorderRadius.circular(_slideBorderRadius),
              border: Border.all(width: 1.0, color: Colors.grey[800]),
            ),
            child: slide,
          );
  }
}
