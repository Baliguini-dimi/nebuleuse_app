import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/quote_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  // 📋 La liste des citations favorites
  List<Map<String, String>> _favorites = [];
  bool _isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    _loadFavorites(); // Charger dès l'ouverture
  }

  // 📖 Charger les favoris depuis le stockage local
  Future<void> _loadFavorites() async {
    final favorites = await QuoteService.getFavorites();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  // 🗑️ Supprimer un favori
  Future<void> _removeFavorite(Map<String, String> quote) async {
    await QuoteService.removeFavorite(quote);
    setState(() {
      _favorites.removeWhere((f) => f['text'] == quote['text']);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retiré des favoris'),
          backgroundColor: Color(0xFF1A1A1A),
          duration: Duration(seconds: 2),
        ),
      );
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
          'FAVORIS',
          style: TextStyle(
            color: Color(0xFFD4A843),
            fontSize: 16,
            fontWeight: FontWeight.w300,
            letterSpacing: 6,
          ),
        ),
        centerTitle: true,
      ),

      body: _isLoading
      // ⏳ Chargement en cours
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4A843),
        ),
      )
      // 📭 Aucun favori
          : _favorites.isEmpty
          ? _buildEmptyState()
      // 📋 Liste des favoris
          : _buildFavoritesList(),
    );
  }

  // 😶 Widget : Écran vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            color: Color(0xFF333333),
            size: 64,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun favori pour l\'instant',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Appuie sur ♡ pour sauvegarder\nune citation',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF444444),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // 📋 Widget : Liste des favoris
  Widget _buildFavoritesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final quote = _favorites[index];
        return _buildQuoteCard(quote);
      },
    );
  }

  // 🃏 Widget : Carte d'une citation
  Widget _buildQuoteCard(Map<String, String> quote) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 💬 Texte de la citation
          Text(
            '"${quote['text']}"',
            style: const TextStyle(
              color: Color(0xFFF5F0E8),
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 12),

          // Ligne de séparation fine
          Container(height: 1, color: const Color(0xFF2A2A2A)),

          const SizedBox(height: 12),

          // 👤 Auteur + boutons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Auteur
              Expanded(
                child: Text(
                  '— ${quote['author']}',
                  style: const TextStyle(
                    color: Color(0xFFD4A843),
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),

              // 📤 Partager
              GestureDetector(
                onTap: () {
                  Share.share(
                    '"${quote['text']}"\n\n— ${quote['author']}\n\n✨ Via Nébuleuse',
                  );
                },
                child: const Icon(
                  Icons.share_outlined,
                  color: Color(0xFF666666),
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              // 🗑️ Supprimer
              GestureDetector(
                onTap: () => _removeFavorite(quote),
                child: const Icon(
                  Icons.favorite,
                  color: Color(0xFFD4A843),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}