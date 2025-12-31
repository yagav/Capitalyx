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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _inputFocusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  bool _isInputMode = false;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _inputFocusNode.removeListener(_onFocusChange);
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isInputMode = _inputFocusNode.hasFocus;
    });
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
      // backgroundColor: Use theme background (now #121212 in dark mode)
      extendBodyBehindAppBar: true, // Allow glow to go behind AppBar
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
        actions: const [
          LanguageSelector(),
          SizedBox(width: 8),
        ],
      ),
      onDrawerChanged: (isOpened) {
        setState(() {
          _isDrawerOpen = isOpened;
        });
      },
      drawerScrimColor: Colors.transparent,
      drawer: _buildSidebar(context, ref, secondaryColor),
      body: GlowBackground(
        secondColor: secondaryColor,
        isDark: isDark,
        child: Stack(
          children: [
            Column(
              children: [
                // Spacer for AppBar since we extended body
                SizedBox(
                    height:
                        kToolbarHeight + MediaQuery.of(context).padding.top),

                // Central Content (Logo + Text)
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isInputMode ? 0.0 : 1.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Placeholder
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
                                color: secondaryColor.withValues(alpha: 0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.star_outline_rounded,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Hello, ${authState.user?.userMetadata?['full_name'] ?? profile?.startupName ?? 'User'}",
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
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

                // Feature Widgets (Single Row)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isInputMode ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: _isInputMode,
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
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                focusNode: _inputFocusNode,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'Ask anything here...',
                                  hintStyle: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5)),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.mic_none,
                                    color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _isInputMode = true;
                                  });
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

            // Blur Overlay (Sidebar)
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

  Widget _buildSidebar(
      BuildContext context, WidgetRef ref, Color secondaryColor) {
    // Re-access theme here correctly
    final themeState = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final isDark = themeState.isDark;

    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF1E1E1E).withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.9), // Slightly transparent
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Icon(Icons.settings, color: theme.colorScheme.onSurface),
                  const SizedBox(width: 12),
                  Text(
                    'Settings',
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
            SwitchListTile(
              title: Text('Dark Mode',
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
            ListTile(
              leading: Icon(Icons.history, color: theme.colorScheme.onSurface),
              title: Text('History',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                ref.read(authProvider.notifier).signOut();
              },
            ),
            const SizedBox(height: 20),
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
                    Text(
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
