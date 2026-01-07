import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:startup_application/presentation/providers/auth_provider.dart';
import 'package:startup_application/presentation/providers/theme_provider.dart';
import 'package:startup_application/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:startup_application/presentation/widgets/glow_background.dart';
import 'package:startup_application/presentation/widgets/language_selector.dart';
import 'package:startup_application/presentation/widgets/translated_text.dart';
import 'package:startup_application/injection_container.dart' as di;
import 'package:startup_application/domain/repositories/query_repository.dart';
import 'package:startup_application/presentation/providers/language_provider.dart';
import 'package:startup_application/core/services/glossary_service.dart';
import 'package:startup_application/core/services/voice_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _inputFocusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final GlossaryService _glossaryService = GlossaryService();

  bool _isInputMode = false;
  bool _isDrawerOpen = false;

  // Voice Service
  final VoiceService _voiceService = VoiceService();
  bool _isRecording = false;

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(_onFocusChange);
    // Check permissions early
    _voiceService.hasPermission();

    // Pulsing Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _inputFocusNode.removeListener(_onFocusChange);
    _inputFocusNode.dispose();
    _textController.dispose();
    _voiceService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isInputMode = _inputFocusNode.hasFocus;
    });
  }

  Future<void> _handleVoiceInteraction() async {
    if (_isRecording) {
      // STOP RECORDING
      setState(() => _isRecording = false);
      final path = await _voiceService.stopRecording();

      if (path != null) {
        await _processVoiceQuery(path);
      }
    } else {
      // START RECORDING
      if (await _voiceService.hasPermission()) {
        await _voiceService.startRecording();
        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _processVoiceQuery(String audioPath) async {
    final currentLangState = ref.read(languageProvider);
    final currentLang = currentLangState.code;

    // Show processing snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: TranslatedText('Processing voice command...')),
    );

    try {
      // Step 1: STT
      final transcript = await _voiceService.transcribe(audioPath, currentLang);

      if (transcript == null || transcript.isEmpty) {
        // Error Handling: Play "Sorry..."
        _playLocalizedFeedback(
            "Sorry, I couldn't hear that. Please try again.", currentLang);
        return;
      }

      // Update UI with transcript
      setState(() {
        _textController.text = transcript;
      });

      // Step 2 & 3: Parallel Execution
      // A. Play Feedback (Fire-and-forget)
      _playLocalizedFeedback(
          "Please wait, your query is being processed.", currentLang);

      // B. Save to DB (Translation handled inside saveProcessedQuery)
      await di
          .sl<QueryRepository>()
          .saveProcessedQuery(transcript, currentLang);

      // Auto-submit interaction if needed or just leave in text box?
      // "Input Focus logic" implies we might want to submit.
      // But prompt says "Insert the result...", implies done.
      // Text box update is nice for feedback.
    } catch (e) {
      print("Error processing voice query: $e");
    }
  }

  // Helper to translate and speak feedback
  void _playLocalizedFeedback(String message, String langCode) async {
    try {
      final translated = await _glossaryService.translate(message, langCode);
      // Fire and forget speech
      _voiceService.speak(translated, langCode);
    } catch (e) {
      print("TTS Feedback Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;

    // Dynamic color based on sector
    final Color secondaryColor =
        AppTheme.getSecondaryColorForSector(profile?.startupSector ?? '');

    // Theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          profile?.startupName ?? 'New Chat',
          style: TextStyle(
              color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded,
                color: theme.colorScheme.onSurface),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      onEndDrawerChanged: (isOpened) {
        setState(() {
          _isDrawerOpen = isOpened;
        });
      },
      drawerScrimColor: Colors.transparent,
      drawer: _buildSidebar(context, ref, secondaryColor),
      endDrawer: _buildRightSidebar(context, ref, secondaryColor),
      body: GlowBackground(
        secondColor: secondaryColor,
        isDark: isDark,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                    height:
                        kToolbarHeight + MediaQuery.of(context).padding.top),

                // Central Content (Logo + Text or Waveform)
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isInputMode || _isRecording ? 0.0 : 1.0,
                    // Hide when input OR recording?
                    // Prompt says "Ensure isInputMode is triggered... so other UI elements remain hidden".
                    // I'll reuse opacity logic or change it.
                    // If recording, we want to show Waveform INSTEAD of these widgets.
                    child: _isRecording
                        ? Center(
                            child: ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: secondaryColor.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          secondaryColor.withValues(alpha: 0.5),
                                      width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          secondaryColor.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Icon(Icons.graphic_eq,
                                      size: 50, color: secondaryColor),
                                ),
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      secondaryColor,
                                      secondaryColor.withValues(alpha: 0.5)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          secondaryColor.withValues(alpha: 0.4),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.star_outline_rounded,
                                    color: Colors.white, size: 40),
                              ),
                              const SizedBox(height: 24),
                              TranslatedText(
                                "Hello, ${authState.user?.userMetadata?['full_name'] ?? profile?.startupName ?? 'User'}",
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TranslatedText(
                                "How can I assist you right now?",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Feature Widgets - Hide when input focused or recording
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isInputMode || _isRecording ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: _isInputMode || _isRecording,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _FeatureCard(
                              title: 'Funding\nReadiness',
                              icon: Icons.monetization_on_outlined,
                              color: secondaryColor,
                              isDark: isDark,
                              onTap: () => context.push('/funding-readiness'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FeatureCard(
                              title: 'Pitch Deck\nAnalyzer',
                              icon: Icons.analytics_outlined,
                              color: secondaryColor,
                              isDark: isDark,
                              onTap: () => context.push('/pitch-deck-analyzer'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FeatureCard(
                              title: 'Investor\nMatching',
                              icon: Icons.people_outline,
                              color: secondaryColor,
                              isDark: isDark,
                              onTap: () => context.push('/investor-matching'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Input Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            )),
                        child: Row(
                          children: [
                            // Mic Button (Left)
                            IconButton(
                              icon: Icon(
                                  _isRecording ? Icons.stop : Icons.mic_none,
                                  color: _isRecording
                                      ? Colors.red
                                      : theme.colorScheme.onSurface),
                              onPressed: _handleVoiceInteraction,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                focusNode: _inputFocusNode,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface),
                                onSubmitted: (value) async {
                                  if (value.trim().isNotEmpty) {
                                    final currentLang =
                                        ref.read(languageProvider);
                                    await di
                                        .sl<QueryRepository>()
                                        .saveProcessedQuery(
                                            value.trim(), currentLang.code);
                                    _textController.clear();
                                    _inputFocusNode.unfocus();
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: _isRecording
                                      ? 'Listening...'
                                      : 'Ask anything here...',
                                  hintStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5)),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical:
                                          14), // reduced padding due to mic
                                ),
                              ),
                            ),
                            // Send Button (Right)
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_upward,
                                    color: Colors.white),
                                onPressed: () async {
                                  final value = _textController.text;
                                  if (value.trim().isNotEmpty) {
                                    final currentLang =
                                        ref.read(languageProvider);
                                    await di
                                        .sl<QueryRepository>()
                                        .saveProcessedQuery(
                                            value.trim(), currentLang.code);
                                    _textController.clear();
                                    _inputFocusNode.unfocus();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Blur Overlay (Backdrop for both Drawers)
            if (_isDrawerOpen)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Right Sidebar (End Drawer)
  Widget _buildRightSidebar(
      BuildContext context, WidgetRef ref, Color secondaryColor) {
    final themeState = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final isDark = themeState.isDark;

    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF1E1E1E).withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.9),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Icon(Icons.settings, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 12),
                  TranslatedText(
                    'Options',
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            // Switch Theme
            SwitchListTile(
              title: TranslatedText('Dark Mode',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              value: isDark,
              activeColor: secondaryColor,
              onChanged: (bool value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.onSurface,
              ),
            ),
            // Language Settings (Using the selector logic or just link)
            ListTile(
              leading: Icon(Icons.language, color: theme.colorScheme.onSurface),
              title: TranslatedText('Language Settings',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              trailing: const LanguageSelector(
                  color: Colors.grey), // Embed selector directly or open dialog
              onTap: () {
                // The LanguageSelector widget handles the click itself mostly, but if we want a full page:
                // context.push('/settings/language');
                // For now, putting the selector as trailing
              },
            ),
            // Logout
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const TranslatedText('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                // Close drawer before sign out to avoid errors
                Navigator.pop(context);
                ref.read(authProvider.notifier).signOut();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Keeping original left sidebar but updating it slightly if necessary or just leaving as 'Menu'
  // Since the user asked for sidebar on "Three Dots" (Right), I moved the requested items there.
  // This one can be "Navigation"
  Widget _buildSidebar(
      BuildContext context, WidgetRef ref, Color secondaryColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF1E1E1E).withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.9),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Icon(Icons.menu, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 12),
                  TranslatedText(
                    'Menu',
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: Icon(Icons.history, color: theme.colorScheme.onSurface),
              title: TranslatedText('History',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {},
            ),
            // ... other items
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 130, // Taller for glass look
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align left like Apple cards
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                            shape: BoxShape.circle),
                        child: Icon(icon,
                            color: isDark ? Colors.white : Colors.black87,
                            size: 24)),
                    TranslatedText(
                      title,
                      style: GoogleFonts.inter(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
