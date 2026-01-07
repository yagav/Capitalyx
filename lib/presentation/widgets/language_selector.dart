import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_application/presentation/providers/language_provider.dart';

class LanguageSelector extends ConsumerWidget {
  final Color color;

  const LanguageSelector({
    super.key,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);

    return PopupMenuButton<String>(
      initialValue: currentLang.code,
      icon: Icon(Icons.language, color: color),
      tooltip: 'Select Language',
      onSelected: (String code) {
        ref.read(languageProvider.notifier).setLanguage(code);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'en',
          child: Text('English'),
        ),
        const PopupMenuItem<String>(
          value: 'ta',
          child: Text('Tamil'),
        ),
        const PopupMenuItem<String>(
          value: 'ml',
          child: Text('Malayalam'),
        ),
        const PopupMenuItem<String>(
          value: 'hi',
          child: Text('Hindi'),
        ),
        const PopupMenuItem<String>(
          value: 'te',
          child: Text('Telugu'),
        ),
        const PopupMenuItem<String>(
          value: 'kn',
          child: Text('Kannada'),
        ),
        const PopupMenuItem<String>(
          value: 'mr',
          child: Text('Marathi'),
        ),
      ],
    );
  }
}
