import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:startup_application/presentation/providers/language_provider.dart';

class TranslatedText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageProvider);

    String displayText = text;
    bool showShimmer = false;

    if (languageState.code != 'en') {
      final translated = languageState.translations[text];
      if (translated != null) {
        displayText = translated;
      } else if (languageState.isLoading) {
        showShimmer = true;
      } else {
        // Not found and not loading? Fallback to original
        // Could technically try to translate on the fly if we supported dynamic strings
        // But for this scope we rely on the batch load.
      }
    }

    if (showShimmer) {
      return Shimmer.fromColors(
        baseColor: (style?.color ?? Colors.white).withValues(alpha: 0.3),
        highlightColor: (style?.color ?? Colors.white).withValues(alpha: 0.1),
        child: Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        ),
      );
    }

    return Text(
      displayText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
