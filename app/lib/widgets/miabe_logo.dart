import 'package:flutter/material.dart';
import 'package:miabeassistant/constants/app_theme.dart';

class MiabeLogo extends StatefulWidget {
  final double size;
  final Color? color;
  final bool isAnimated;

  const MiabeLogo({
    super.key,
    this.size = 100,
    this.color,
    this.isAnimated = false,
  });

  @override
  State<MiabeLogo> createState() => _MiabeLogoState();
}

class _MiabeLogoState extends State<MiabeLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    if (widget.isAnimated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant MiabeLogo oldWidget) {
    if (widget.isAnimated && !oldWidget.isAnimated) {
      _controller.forward(from: 0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? AppTheme.primary;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Image.asset(
          'assets/images/miabe_logo.png',
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}


