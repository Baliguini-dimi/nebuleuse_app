import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class QuoteService {

  // 🔑 Clés SharedPreferences
  static const String _favoritesKey = 'favorites';
  static const String _cachedQuotesKey = 'cached_quotes';

  // ═══════════════════════════════════
  // ⭐ GESTION DES FAVORIS
  // ═══════════════════════════════════

  // 📖 Lire tous les favoris
  static Future<List<Map<String, String>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_favoritesKey) ?? [];
    return jsonList
        .map((item) => Map<String, String>.from(jsonDecode(item)))
        .toList();
  }

  // 💾 Ajouter un favori
  static Future<bool> addFavorite(Map<String, String> quote) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_favoritesKey) ?? [];

    // Vérifier doublon
    final exists = jsonList.any((item) {
      final decoded = Map<String, String>.from(jsonDecode(item));
      return decoded['text'] == quote['text'];
    });

    if (exists) return false;

    jsonList.add(jsonEncode(quote));
    await prefs.setStringList(_favoritesKey, jsonList);
    return true;
  }

  // 🗑️ Supprimer un favori
  static Future<void> removeFavorite(Map<String, String> quote) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_favoritesKey) ?? [];
    jsonList.removeWhere((item) {
      final decoded = Map<String, String>.from(jsonDecode(item));
      return decoded['text'] == quote['text'];
    });
    await prefs.setStringList(_favoritesKey, jsonList);
  }

  // ❓ Vérifier si favori
  static Future<bool> isFavorite(Map<String, String> quote) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f['text'] == quote['text']);
  }

  // ═══════════════════════════════════
  // 🌐 MODE ONLINE — API GROQ
  // ═══════════════════════════════════

  // 🤖 Générer une nouvelle citation via Groq
  static Future<Map<String, String>?> generateQuoteFromGroq() async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.groqBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.groqApiKey}',
        },
        body: jsonEncode({
          "model": AppConfig.groqModel,
          "messages": [
            {
              "role": "system",
              "content": """Tu es un sage africain moderne. 
Tu génères des citations ORIGINALES, profondes et percutantes 
inspirées de la sagesse africaine, des proverbes, des leaders et 
philosophies africaines.

RÈGLES STRICTES :
- La citation doit être ORIGINALE (pas copiée)
- Ton : direct, profond, poétique OU foudroyant
- Longueur : entre 10 et 40 mots maximum
- Langue : français uniquement
- L'auteur peut être : un leader africain réel, 
  "Proverbe africain", "Sagesse africaine", 
  "Ubuntu — Philosophie africaine", etc.

RÉPONDS UNIQUEMENT avec ce JSON exact, rien d'autre :
{"text": "La citation ici", "author": "L'auteur ici"}"""
            },
            {
              "role": "user",
              "content": "Génère une nouvelle citation africaine percutante."
            }
          ],
          "temperature": 0.9,  // Créativité élevée
          "max_tokens": 200,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].toString().trim();

        // Nettoyer et parser le JSON reçu
        final cleaned = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        final quote = Map<String, String>.from(jsonDecode(cleaned));

        // Vérifier que les champs existent
        if (quote.containsKey('text') && quote.containsKey('author')) {
          // Sauvegarder dans le cache local
          await _cacheQuote(quote);
          return quote;
        }
      }

      return null; // Échec → on utilisera le mode offline

    } catch (e) {
      // Erreur réseau ou parsing → mode offline
      return null;
    }
  }

  // ═══════════════════════════════════
  // 📦 GESTION DU CACHE LOCAL (≤ 50)
  // ═══════════════════════════════════

  // 💾 Sauvegarder une citation générée dans le cache
  static Future<void> _cacheQuote(Map<String, String> quote) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cached = prefs.getStringList(_cachedQuotesKey) ?? [];

    // Vérifier doublon
    final exists = cached.any((item) {
      final decoded = Map<String, String>.from(jsonDecode(item));
      return decoded['text'] == quote['text'];
    });

    if (exists) return;

    // Si on dépasse 50 → supprimer la plus ancienne
    if (cached.length >= AppConfig.maxLocalQuotes) {
      cached.removeAt(0); // Supprimer la première (la plus vieille)
    }

    cached.add(jsonEncode(quote));
    await prefs.setStringList(_cachedQuotesKey, cached);
  }

  // 📖 Lire les citations du cache
  static Future<List<Map<String, String>>> getCachedQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> cached = prefs.getStringList(_cachedQuotesKey) ?? [];
    return cached
        .map((item) => Map<String, String>.from(jsonDecode(item)))
        .toList();
  }

  // 🎲 Citation aléatoire depuis le cache
  static Future<Map<String, String>?> getRandomCachedQuote() async {
    final cached = await getCachedQuotes();
    if (cached.isEmpty) return null;
    return cached[Random().nextInt(cached.length)];
  }
}