import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/local_quotes.dart';
import '../services/quote_service.dart';
import 'favorites_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  Map<String, String> _currentQuote = localQuotes[0];
  bool _isFavorite = false;
  bool _isLoadingOnline = false;

  // 🎬 Animations multiples
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _nextQuote() async {
    await _animController.reverse();
    setState(() => _isLoadingOnline = true);

    Map<String, String>? newQuote = await QuoteService.generateQuoteFromGroq();

    if (newQuote == null) {
      final random = Random();
      Map<String, String> localQuote;
      do {
        localQuote = localQuotes[random.nextInt(localQuotes.length)];
      } while (localQuote["text"] == _currentQuote["text"]);
      newQuote = localQuote;
    }

    setState(() {
      _currentQuote = newQuote!;
      _isLoadingOnline = false;
    });

    _animController.forward();
    _checkFavoriteStatus();
  }

  void _shareQuote() {
    final text =
        '"${_currentQuote["text"]}"\n\n— ${_currentQuote["author"]}\n\n✨ Via Nébuleuse';
    Share.share(text);
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await QuoteService.isFavorite(_currentQuote);
    if (mounted) setState(() => _isFavorite = status);
  }

  Future<void> _toggleFavorite() async {
    final added = await QuoteService.addFavorite(_currentQuote);
    setState(() => _isFavorite = added);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              added ? '⭐ Ajouté aux favoris !' : 'Déjà dans les favoris'),
          backgroundColor: const Color(0xFF1A1A1A),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDarkMode, _) {

        final bg = isDarkMode
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF5F0E8);
        final drawerColor = isDarkMode
            ? const Color(0xFF0D0D0D)
            : const Color(0xFFEDE8DF);
        final quoteTextColor = isDarkMode
            ? const Color(0xFFF5F0E8)
            : const Color(0xFF1A1A1A);

        return Scaffold(
          backgroundColor: bg,

          // ════════════════════════════
          // ☰ DRAWER
          // ════════════════════════════
          drawer: Drawer(
            backgroundColor: drawerColor,
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 24),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDarkMode
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFD4C5A9),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFD4A843), width: 1.5),
                            color: isDarkMode
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFFE8E0D0),
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: Color(0xFFD4A843), size: 28),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'NÉBULEUSE',
                          style: TextStyle(
                            color: Color(0xFFD4A843),
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sagesse africaine moderne',
                          style: TextStyle(
                            color: isDarkMode
                                ? const Color(0xFF555555)
                                : const Color(0xFF888888),
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildDrawerItem(icon: Icons.home_outlined,
                      label: 'Accueil', isDark: isDarkMode,
                      onTap: () => Navigator.pop(context)),
                  _buildDrawerItem(icon: Icons.favorite_border,
                      label: 'Mes Favoris', isDark: isDarkMode,
                      onTap: () => _navigateTo(const FavoritesScreen())),
                  _buildDrawerItem(icon: Icons.settings_outlined,
                      label: 'Paramètres', isDark: isDarkMode,
                      onTap: () => _navigateTo(const SettingsScreen())),
                  _buildDrawerItem(icon: Icons.info_outline,
                      label: 'À propos', isDark: isDarkMode,
                      onTap: () => _navigateTo(const AboutScreen())),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(height: 1,
                            color: isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFD4C5A9)),
                        const SizedBox(height: 16),
                        Text(
                          '✨ Fait avec passion en Côte d\'Ivoire',
                          style: TextStyle(
                            color: isDarkMode
                                ? const Color(0xFF333333)
                                : const Color(0xFF999999),
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '© 2025 Nébuleuse v1.0.0',
                          style: TextStyle(
                            color: isDarkMode
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFAAAAAA),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ════════════════════════════
          // 🔝 APPBAR
          // ════════════════════════════
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu,
                    color: Color(0xFFD4A843), size: 26),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const Text(
              'NÉBULEUSE',
              style: TextStyle(
                color: Color(0xFFD4A843),
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 6,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFFD4A843),
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),

          // ════════════════════════════
          // 📄 CORPS avec étoiles
          // ════════════════════════════
          body: Stack(
            children: [

              // ✨ Étoiles flottantes en arrière-plan
              const StarFieldBackground(),

              // 📄 Contenu principal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    _buildGoldenDivider(),
                    const SizedBox(height: 32),

                    // Chargement ou citation
                    _isLoadingOnline
                        ? SizedBox(
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFFD4A843),
                            strokeWidth: 1.5,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'La sagesse arrive...',
                            style: TextStyle(
                              color: isDarkMode
                                  ? const Color(0xFF555555)
                                  : const Color(0xFF888888),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    )

                    // ✨ Citation avec Fade + Scale + Slide
                        : FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ValueListenableBuilder<double>(
                            valueListenable: fontSizeNotifier,
                            builder: (context, fontSize, _) {
                              return Column(
                                children: [
                                  const Text(
                                    '❝',
                                    style: TextStyle(
                                      color: Color(0xFFD4A843),
                                      fontSize: 48,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _currentQuote["text"]!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: quoteTextColor,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w300,
                                      height: 1.7,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    '— ${_currentQuote["author"]}',
                                    style: const TextStyle(
                                      color: Color(0xFFD4A843),
                                      fontSize: 14,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    _buildGoldenDivider(),
                    const SizedBox(height: 60),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════
  // 🧩 WIDGETS
  // ════════════════════════════════

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: const Color(0xFFD4A843), size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF333333),
          fontSize: 15,
          letterSpacing: 1,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFBBBBBB),
        size: 14,
      ),
      onTap: onTap,
    );
  }

  Widget _buildGoldenDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 60, height: 1, color: const Color(0xFFD4A843)),
        const SizedBox(width: 8),
        const Icon(Icons.star, color: Color(0xFFD4A843), size: 10),
        const SizedBox(width: 8),
        Container(width: 60, height: 1, color: const Color(0xFFD4A843)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [

        // 💛 Bouton Favoris avec glow
        _GlowButton(
          icon: Icons.favorite_border,
          label: 'Favoris',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen())),
        ),

        // 🔄 Bouton central avec glow
        _GlowCenterButton(
          isLoading: _isLoadingOnline,
          onTap: _isLoadingOnline ? null : _nextQuote,
        ),

        // 📤 Bouton Partager avec glow
        _GlowButton(
          icon: Icons.share_outlined,
          label: 'Partager',
          onTap: _shareQuote,
        ),
      ],
    );
  }
}

// ════════════════════════════════════
// 💛 BOUTON ICÔNE AVEC GLOW
// ════════════════════════════════════

class _GlowButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GlowButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 14.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4A843)
                            .withOpacity(_glowAnim.value / 14 * 0.7),
                        blurRadius: _glowAnim.value,
                        spreadRadius: _glowAnim.value * 0.3,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: const Color(0xFFD4A843),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════
// 🔄 BOUTON CENTRAL AVEC GLOW
// ════════════════════════════════════

class _GlowCenterButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _GlowCenterButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_GlowCenterButton> createState() => _GlowCenterButtonState();
}

class _GlowCenterButtonState extends State<_GlowCenterButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isLoading
        ? const Color(0xFF444444)
        : const Color(0xFFD4A843);

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null ? (_) {
        _controller.reverse();
        widget.onTap!();
      } : null,
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4A843)
                        .withOpacity(_glowAnim.value / 20 * 0.5),
                    blurRadius: _glowAnim.value,
                    spreadRadius: _glowAnim.value * 0.2,
                  ),
                ],
              ),
              child: Icon(Icons.refresh, color: color, size: 30),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════
// ✨ ÉTOILES FLOTTANTES (ARRIÈRE-PLAN)
// ════════════════════════════════════

class StarFieldBackground extends StatefulWidget {
  const StarFieldBackground({super.key});

  @override
  State<StarFieldBackground> createState() => _StarFieldBackgroundState();
}

class _StarFieldBackgroundState extends State<StarFieldBackground>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  final List<_StarData> _stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    final random = Random();
    for (int i = 0; i < 30; i++) {
      _stars.add(_StarData(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 1.8 + 0.4,
        opacity: random.nextDouble() * 0.35 + 0.05,
        speed: random.nextDouble() * 0.4 + 0.1,
        phase: random.nextDouble() * 2 * pi,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _StarBackgroundPainter(_stars, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _StarData {
  final double x, y, size, opacity, speed, phase;
  _StarData({
    required this.x, required this.y,
    required this.size, required this.opacity,
    required this.speed, required this.phase,
  });
}

class _StarBackgroundPainter extends CustomPainter {
  final List<_StarData> stars;
  final double progress;

  _StarBackgroundPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle =
          (sin(progress * 2 * pi * star.speed + star.phase) + 1) / 2;
      final currentOpacity = star.opacity * (0.3 + twinkle * 0.7);
      final paint = Paint()
        ..color = const Color(0xFFD4A843).withOpacity(currentOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * (0.7 + twinkle * 0.4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarBackgroundPainter old) => true;
}