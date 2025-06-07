import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
  final bool showIndicators;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const ImageCarousel({
    super.key,
    required this.images,
    this.height = 400,
    this.showIndicators = true,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: PageView.builder(
              itemCount: widget.images.length,
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 50),
                    );
                  },
                );
              },
            ),
          ),
        ),
        if (widget.showBackButton)
          Positioned(
            top: 40,
            left: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
              ),
            ),
          ),
        if (widget.showIndicators)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.circle,
                    size: 10,
                    color: _currentPage == index ? Colors.black : Colors.grey[300],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 