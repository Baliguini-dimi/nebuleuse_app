class AppConfig {
  // Obtenue sur : console.groq.com/keys
  static const String groqApiKey = 'API_KEY_HERE';

  // 🤖 Modèle Groq utilisé (rapide + gratuit)
  static const String groqModel = 'llama3-8b-8192';

  // 🌐 URL de l'API
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // 📦 Nombre max de citations en local
  static const int maxLocalQuotes = 50;
}