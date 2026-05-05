import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // 🎬 Contrôleurs d'animation
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _glowController;
  late AnimationController _starsController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _glowRadius;

  @override
  void initState() {
    super.initState();

    // Logo : scale + fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    // Texte : fade + slide up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Glow pulsant autour du logo
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowRadius = Tween<double>(begin: 15.0, end: 35.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Étoiles flottantes
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Séquence d'animations
    _startSequence();
  }

  Future<void> _startSequence() async {
    // 1. Logo apparaît
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // 2. Texte apparaît
    await Future.delayed(const Duration(milliseconds: 900));
    _textController.forward();

    // 3. Naviguer vers Home
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _glowController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [

          // ✨ Étoiles en arrière-plan
          const _StarField(),

          // Centre : Logo + Texte
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // 🌟 Logo avec glow
                AnimatedBuilder(
                  animation: Listenable.merge(
                      [_logoController, _glowController]),
                  builder: (context, _) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4A843),
                              width: 1.5,
                            ),
                            color: const Color(0xFF0A0A0A),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4A843)
                                    .withOpacity(0.4),
                                blurRadius: _glowRadius.value,
                                spreadRadius: _glowRadius.value * 0.3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFD4A843),
                            size: 56,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // 📝 Texte animé
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _textOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: Column(
                          children: [
                            // Titre
                            const Text(
                              'NÉBULEUSE',
                              style: TextStyle(
                                color: Color(0xFFD4A843),
                                fontSize: 28,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 10,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Ligne décorative
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: 40,
                                    height: 1,
                                    color: const Color(0xFFD4A843)
                                        .withOpacity(0.5)),
                                const SizedBox(width: 8),
                                const Icon(Icons.star,
                                    color: Color(0xFFD4A843), size: 8),
                                const SizedBox(width: 8),
                                Container(
                                    width: 40,
                                    height: 1,
                                    color: const Color(0xFFD4A843)
                                        .withOpacity(0.5)),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Sous-titre
                            const Text(
                              'Sagesse africaine moderne',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 13,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Signature bas de page
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, _) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: const Text(
                    '✨ Fait avec passion en Côte d\'Ivoire',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════
// ✨ WIDGET ÉTOILES FLOTTANTES
// ════════════════════════════════════

class _StarField extends StatefulWidget {
  const _StarField();

  @override
  State<_StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<_StarField>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  final List<_Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Générer 40 étoiles aléatoires
    final random = Random();
    for (int i = 0; i < 40; i++) {
      _stars.add(_Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2.5 + 0.5,
        opacity: random.nextDouble() * 0.6 + 0.1,
        speed: random.nextDouble() * 0.5 + 0.2,
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
          painter: _StarPainter(_stars, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Star {
  final double x, y, size, opacity, speed, phase;
  _Star({
    required this.x, required this.y, required this.size,
    required this.opacity, required this.speed, required this.phase,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress;

  _StarPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // Scintillement via sinus
      final twinkle = (sin(progress * 2 * pi * star.speed + star.phase) + 1) / 2;
      final currentOpacity = star.opacity * (0.3 + twinkle * 0.7);

      final paint = Paint()
        ..color = const Color(0xFFD4A843).withOpacity(currentOpacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size * (0.7 + twinkle * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => true;
}