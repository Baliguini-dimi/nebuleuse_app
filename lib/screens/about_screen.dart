import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // 🔗 Ouvrir un lien externe
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Erreur ouverture lien : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ APRÈS — couleur dynamique selon le thème
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFFD4A843), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'À PROPOS',
          style: TextStyle(
            color: Color(0xFFD4A843),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            letterSpacing: 6,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [

            const SizedBox(height: 20),

            // ════════════════════════════════
            // 🌟 SECTION APP
            // ════════════════════════════════

            // Logo de l'app
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4A843), width: 1.5),
                color: const Color(0xFF141414),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFFD4A843),
                size: 44,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'NÉBULEUSE',
              style: TextStyle(
                color: Color(0xFFD4A843),
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 8,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Color(0xFF555555), fontSize: 12),
            ),

            const SizedBox(height: 16),

            const Text(
              'Sagesse africaine moderne — des mots qui élèvent,\n'
                  'des pensées qui transforment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 13,
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 32),
            _buildDivider(),
            const SizedBox(height: 32),

            // ════════════════════════════════
            // 👤 SECTION CRÉATEUR
            // ════════════════════════════════

            const Text(
              'LE CRÉATEUR',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 11,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 24),

// Photo de profil réelle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4A843), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4A843).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/images/profile.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nom
            const Text(
              'Dimitri Nelson BALIGUINI',
              style: TextStyle(
                color: Color(0xFFF5F0E8),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Développeur · Infographiste · Entrepreneur',
              style: TextStyle(
                color: Color(0xFFD4A843),
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              '🇨🇫 Centrafrique · 🇨🇮 Côte d\'Ivoire',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 28),

            // Biographie
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
              ),
              child: const Text(
                'Jeune Centrafricain passionné par le digital, '
                    'Dimitri construit un parcours à la croisée de l\'informatique, '
                    'du marketing et du leadership. Étudiant en Master Génie Informatique '
                    'en Côte d\'Ivoire, il conçoit des solutions digitales innovantes '
                    'avec une vision claire : apprendre, créer, et contribuer '
                    'à transformer son continent.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 14,
                  height: 1.8,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 32),
            _buildDivider(),
            const SizedBox(height: 32),

            // ════════════════════════════════
            // 💼 SECTION PROJETS
            // ════════════════════════════════

            const Text(
              'PROJETS RÉALISÉS',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 11,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 20),

            _buildProjectCard(
              icon: Icons.store_outlined,
              title: 'Glory Market',
              description: 'Plateforme web multi-services (IT, BTP, décoration, traiteur…) '
                  'avec gestion admin, catalogue CRUD et filtrage dynamique.',
              tech: 'HTML · CSS · PHP · SQL',
            ),

            const SizedBox(height: 12),

            _buildProjectCard(
              icon: Icons.menu_book_outlined,
              title: 'Blog de Révision Collaboratif',
              description: 'Blog WordPress collaboratif avec fiches de révision, '
                  'planning, statistiques, partage de fichiers et offres de stage.',
              tech: 'WordPress · PHP',
            ),

            const SizedBox(height: 12),

            _buildProjectCard(
              icon: Icons.shopping_bag_outlined,
              title: 'App E-commerce Mobile',
              description: 'Application mobile e-commerce développée avec Flutter '
                  'sur template Shope — catalogue produits et navigation.',
              tech: 'Flutter · Dart',
            ),

            const SizedBox(height: 12),

            _buildProjectCard(
              icon: Icons.web_outlined,
              title: 'Site Web Personnel',
              description: 'Portfolio personnel avec frontend HTML/CSS, '
                  'JavaScript interactif et backend PHP en développement.',
              tech: 'HTML · CSS · JS · PHP',
            ),

            const SizedBox(height: 12),

            _buildProjectCard(
              icon: Icons.auto_awesome_outlined,
              title: 'Nébuleuse',
              description: 'Application mobile de citations africaines inspirantes '
                  'avec mode offline, favoris et intégration IA.',
              tech: 'Flutter · Dart · Groq API',
            ),

            const SizedBox(height: 32),
            _buildDivider(),
            const SizedBox(height: 32),

            // ════════════════════════════════
            // 📞 SECTION CONTACT
            // ════════════════════════════════

            const Text(
              'ME CONTACTER',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 11,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 20),

            // Gmail
            _buildContactButton(
              icon: Icons.email_outlined,
              label: 'dbaliguini@gmail.com',
              sublabel: 'Gmail',
              color: const Color(0xFFEA4335),
              onTap: () => _launchUrl('mailto:dbaliguini@gmail.com'),
            ),

            const SizedBox(height: 12),

            // WhatsApp
            _buildContactButton(
              icon: Icons.chat_outlined,
              label: '+236 72 38 03 84',
              sublabel: 'WhatsApp',
              color: const Color(0xFF25D366),
              onTap: () => _launchUrl('https://wa.me/23672380384'),
            ),

            const SizedBox(height: 12),

            // Facebook
            _buildContactButton(
              icon: Icons.facebook_outlined,
              label: 'Dimitri Nelson Baliguini',
              sublabel: 'Facebook',
              color: const Color(0xFF1877F2),
              onTap: () =>
                  _launchUrl('https://www.facebook.com/share/1ACBd5TkCr/'),
            ),

            const SizedBox(height: 12),

            // Instagram
            _buildContactButton(
              icon: Icons.camera_alt_outlined,
              label: '@dems_nb',
              sublabel: 'Instagram',
              color: const Color(0xFFE1306C),
              onTap: () => _launchUrl(
                  'https://www.instagram.com/dems_nb?igsh=MWtzNnhlNHZqY3ZqZg=='),
            ),

            const SizedBox(height: 12),

            // LinkedIn
            _buildContactButton(
              icon: Icons.work_outline,
              label: 'Dimitri Baligini',
              sublabel: 'LinkedIn',
              color: const Color(0xFF0A66C2),
              onTap: () => _launchUrl(
                  'https://www.linkedin.com/in/dimitri-baligini-4b17b32ba'),
            ),

            const SizedBox(height: 48),

            // ════════════════════════════════
            // 💛 Signature
            // ════════════════════════════════

            const Text(
              '✨ Fait avec passion en Côte d\'Ivoire',
              style: TextStyle(
                color: Color(0xFF444444),
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '© 2025 Nébuleuse — Dimitri Nelson BALIGUINI',
              style: TextStyle(color: Color(0xFF333333), fontSize: 11),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ✨ Ligne décorative
  Widget _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: const Color(0xFF2A2A2A)),
        const SizedBox(width: 8),
        const Icon(Icons.auto_awesome, color: Color(0xFFD4A843), size: 10),
        const SizedBox(width: 8),
        Container(width: 40, height: 1, color: const Color(0xFF2A2A2A)),
      ],
    );
  }

  // 💼 Carte de projet
  Widget _buildProjectCard({
    required IconData icon,
    required String title,
    required String description,
    required String tech,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFD4A843), size: 22),
          ),

          const SizedBox(width: 16),

          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFF5F0E8),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Badge technos
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                    border:
                    Border.all(color: const Color(0xFF2A2A2A), width: 1),
                  ),
                  child: Text(
                    tech,
                    style: const TextStyle(
                      color: Color(0xFFD4A843),
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📞 Bouton contact
  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
        ),
        child: Row(
          children: [
            // Icône colorée
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),

            const SizedBox(width: 16),

            // Texte
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sublabel,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF333333),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}