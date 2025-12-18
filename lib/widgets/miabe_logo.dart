import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MiabeLogo extends StatelessWidget {
  final double size;
  final bool withText;
  final Color? color;

  const MiabeLogo({
    super.key,
    this.size = 100,
    this.withText = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = color ?? colorScheme.primary;
    final secondaryColor = colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: size * 0.2,
                offset: Offset(0, size * 0.1),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              FontAwesomeIcons.graduationCap,
              size: size * 0.5,
              color: Colors.white,
            ),
          ),
        ),
        if (withText) ...[
          SizedBox(height: size * 0.1),
          Text(
            'Miabe Assistant',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: size * 0.25,
            ),
          ),
        ],
      ],
    );
  }
}
