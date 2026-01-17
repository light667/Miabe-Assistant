import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';

class MentionText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;

  const MentionText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    // Regex pour détecter [@label](url)
    final RegExp mentionRegex = RegExp(r'\[@([^\]]+)\]\(([^\)]+)\)');
    
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final Match match in mentionRegex.allMatches(text)) {
      // Texte avant la mention
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
      }

      final String label = match.group(1)!;
      final String url = match.group(2)!;

      // La mention elle-même
      spans.add(TextSpan(
        text: '@$label',
        style: (style ?? const TextStyle()).copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
        recognizer: _TapGestureRecognizerWithUrl(url),
      ));

      lastIndex = match.end;
    }

    // Texte après la dernière mention
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: style,
      ));
    }

    if (spans.isEmpty && text.isNotEmpty) {
      spans.add(TextSpan(text: text, style: style));
    }

    return RichText(
      text: TextSpan(children: spans, style: style),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Helper pour gérer le clic sans ajouter une dépendance complexe si possible
// Mais en Flutter, RichText a besoin de GestureRecognizer

class _TapGestureRecognizerWithUrl extends TapGestureRecognizer {
  final String url;

  _TapGestureRecognizerWithUrl(this.url) {
    onTap = () async {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    };
  }
}
