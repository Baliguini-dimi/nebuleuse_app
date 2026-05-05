import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  // ⚙️ Valeurs des paramètres
  bool _darkMode = true;
  bool _notifications = false;
  double _fontSize = 22;
  String _language = 'FR';

  // 🔔 Paramètres notifications ← AJOUTÉ
  String _notifMode = 'daily';
  int _notifHour = 8;
  int _notifMinute = 0;
  int _notifInterval = 1;

  // 🔑 Clés de stockage
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsKey = 'notifications';
  static const String _fontSizeKey = 'font_size';
  static const String _languageKey = 'language';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final notifSettings = await NotificationService.getSavedSettings();

    setState(() {
      _darkMode = prefs.getBool(_darkModeKey) ?? true;
      _notifications = prefs.getBool(_notificationsKey) ?? false;
      _fontSize = prefs.getDouble(_fontSizeKey) ?? 22;
      _language = prefs.getString(_languageKey) ?? 'FR';

      _notifMode = notifSettings['mode'] ?? 'daily';
      _notifHour = notifSettings['hour'] ?? 8;
      _notifMinute = notifSettings['minute'] ?? 0;
      _notifInterval = notifSettings['interval'] ?? 1;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFFD4A843), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PARAMÈTRES',
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 8),

            // ════════════════════════════════
            // 🎨 APPARENCE
            // ════════════════════════════════
            _buildSectionTitle('APPARENCE'),
            const SizedBox(height: 12),

            _buildSwitchTile(
              icon: _darkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              title: 'Mode sombre',
              subtitle: _darkMode
                  ? 'Activé — fond noir élégant'
                  : 'Désactivé — fond clair',
              value: _darkMode,
              onChanged: (val) async {
                setState(() => _darkMode = val);
                await _saveBool(_darkModeKey, val);
                darkModeNotifier.value = val;
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(val
                          ? '🌙 Mode sombre activé'
                          : '☀️ Mode clair activé'),
                      backgroundColor: const Color(0xFF1A1A1A),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 12),

            _buildSliderTile(
              icon: Icons.format_size_outlined,
              title: 'Taille du texte',
              subtitle: 'Taille actuelle : ${_fontSize.toInt()} px',
              value: _fontSize,
              min: 16,
              max: 30,
              onChanged: (val) async {
                setState(() => _fontSize = val);
                await _saveDouble(_fontSizeKey, val);
                fontSizeNotifier.value = val;
              },
              preview: Text(
                '« Le lion ne recule jamais »',
                style: TextStyle(
                  color: const Color(0xFFF5F0E8),
                  fontSize: _fontSize * 0.65,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // ════════════════════════════════
            // 🌍 LANGUE
            // ════════════════════════════════
            _buildSectionTitle('LANGUE'),
            const SizedBox(height: 12),
            _buildLanguageTile(),

            const SizedBox(height: 24),

            // ════════════════════════════════
            // 🔔 NOTIFICATIONS
            // ════════════════════════════════
            _buildSectionTitle('NOTIFICATIONS'),
            const SizedBox(height: 12),

            // Toggle ON/OFF
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Citation du jour',
              subtitle: _notifications
                  ? 'Activées — configure l\'horaire ci-dessous'
                  : 'Reçois une citation inspirante',
              value: _notifications,
              onChanged: (val) async {
                setState(() => _notifications = val);
                await _saveBool(_notificationsKey, val);
                if (!val) {
                  await NotificationService.cancelAllNotifications();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔕 Notifications désactivées'),
                        backgroundColor: Color(0xFF1A1A1A),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),

            if (_notifications) ...[
              const SizedBox(height: 16),

              // Sélecteur de mode
              _buildSectionTitle('MODE DE RÉCEPTION'),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildModeButton('🕗  Heure fixe', 'daily'),
                  const SizedBox(width: 12),
                  _buildModeButton('⏱️  Intervalle', 'interval'),
                ],
              ),

              const SizedBox(height: 16),

              // ── MODE HEURE FIXE ──
              if (_notifMode == 'daily')
                _buildActionTile(
                  icon: Icons.access_time_outlined,
                  title: 'Heure de réception',
                  subtitle: 'Chaque jour à ${_notifHour.toString().padLeft(2, '0')}h${_notifMinute.toString().padLeft(2, '0')}',
                  iconColor: const Color(0xFFD4A843),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: _notifHour, minute: _notifMinute),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFFD4A843),
                              surface: Color(0xFF1A1A1A),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (picked != null) {
                      setState(() {
                        _notifHour = picked.hour;
                        _notifMinute = picked.minute;
                      });

                      await NotificationService.scheduleDailyAtTime(
                        hour: picked.hour,
                        minute: picked.minute,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🔔 Citation programmée à ${picked.hour.toString().padLeft(2, '0')}h${picked.minute.toString().padLeft(2, '0')} chaque jour !',
                            ),
                            backgroundColor: const Color(0xFF1A1A1A),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                ),

              // ── MODE INTERVALLE ──
              if (_notifMode == 'interval')
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF1E1E1E), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.timer_outlined,
                                color: Color(0xFFD4A843), size: 20),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Intervalle',
                                  style: TextStyle(
                                      color: Color(0xFFF5F0E8),
                                      fontSize: 14)),
                              Text(
                                'Toutes les $_notifInterval heure(s)',
                                style: const TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIntervalButton('1h', 1),
                          _buildIntervalButton('3h', 3),
                          _buildIntervalButton('5h', 5),
                          _buildIntervalButton('8h', 8),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Bouton test
              _buildActionTile(
                icon: Icons.notifications_active_outlined,
                title: 'Tester maintenant',
                subtitle: 'Recevoir une notification de test immédiatement',
                iconColor: const Color(0xFFD4A843),
                onTap: () async {
                  await NotificationService.showTestNotification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            '📨 Notification envoyée ! Vérifie ta barre de statut.'),
                        backgroundColor: Color(0xFF1A1A1A),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            ],

            const SizedBox(height: 24),

            // ════════════════════════════════
            // 🗑️ DONNÉES
            // ════════════════════════════════
            _buildSectionTitle('DONNÉES'),
            const SizedBox(height: 12),

            _buildActionTile(
              icon: Icons.favorite_border,
              title: 'Vider les favoris',
              subtitle: 'Supprimer toutes les citations sauvegardées',
              iconColor: const Color(0xFFE57373),
              onTap: () => _showConfirmDialog(
                title: 'Vider les favoris ?',
                message:
                'Toutes tes citations favorites seront supprimées.',
                onConfirm: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('favorites');
                  await prefs.remove('cached_quotes');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🗑️ Favoris supprimés avec succès'),
                        backgroundColor: Color(0xFF1A1A1A),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            _buildActionTile(
              icon: Icons.restart_alt_outlined,
              title: 'Réinitialiser l\'app',
              subtitle: 'Remettre tous les paramètres par défaut',
              iconColor: const Color(0xFFE57373),
              onTap: () => _showConfirmDialog(
                title: 'Réinitialiser ?',
                message:
                'Tous tes paramètres et favoris seront supprimés.',
                onConfirm: () async {
                  await NotificationService.cancelAllNotifications();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  setState(() {
                    _darkMode = true;
                    _notifications = false;
                    _fontSize = 22;
                    _language = 'FR';
                    _notifMode = 'daily';
                    _notifHour = 8;
                    _notifMinute = 0;
                    _notifInterval = 1;
                  });
                  darkModeNotifier.value = true;
                  fontSizeNotifier.value = 22;
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ App réinitialisée avec succès'),
                        backgroundColor: Color(0xFF1A1A1A),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 40),

            const Center(
              child: Text(
                'Nébuleuse — Version 1.0.0',
                style: TextStyle(color: Color(0xFF333333), fontSize: 12),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════
  // 🧩 WIDGETS RÉUTILISABLES
  // ════════════════════════════════

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF555555),
        fontSize: 11,
        letterSpacing: 4,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFD4A843), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFFF5F0E8), fontSize: 14)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF666666), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFD4A843),
            inactiveThumbColor: const Color(0xFF444444),
            inactiveTrackColor: const Color(0xFF222222),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required Widget preview,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon,
                    color: const Color(0xFFD4A843), size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFFF5F0E8), fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF666666), fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFD4A843),
              inactiveTrackColor: const Color(0xFF2A2A2A),
              thumbColor: const Color(0xFFD4A843),
              overlayColor:
              const Color(0xFFD4A843).withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: 7,
              onChanged: onChanged,
            ),
          ),
          Center(child: preview),
        ],
      ),
    );
  }

  Widget _buildLanguageTile() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.language_outlined,
                    color: Color(0xFFD4A843), size: 20),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Langue',
                      style: TextStyle(
                          color: Color(0xFFF5F0E8), fontSize: 14)),
                  Text('Langue des citations',
                      style: TextStyle(
                          color: Color(0xFF666666), fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLangButton('🇫🇷  Français', 'FR'),
              const SizedBox(width: 12),
              _buildLangButton('🇬🇧  English', 'EN'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String label, String code) {
    final isSelected = _language == code;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _language = code);
          _saveString(_languageKey, code);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Langue : $label'),
              backgroundColor: const Color(0xFF1A1A1A),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD4A843).withOpacity(0.15)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD4A843)
                  : const Color(0xFF2A2A2A),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFD4A843)
                  : const Color(0xFF666666),
              fontSize: 13,
              fontWeight:
              isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, String mode) {
    final isSelected = _notifMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _notifMode = mode);
          _saveString('notif_mode', mode);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD4A843).withOpacity(0.15)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD4A843)
                  : const Color(0xFF2A2A2A),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFD4A843)
                  : const Color(0xFF666666),
              fontSize: 13,
              fontWeight:
              isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalButton(String label, int hours) {
    final isSelected = _notifInterval == hours;
    return GestureDetector(
      onTap: () async {
        setState(() => _notifInterval = hours);
        await NotificationService.scheduleInterval(hours: hours);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⏱️ Citation toutes les $hours heure(s) !'),
              backgroundColor: const Color(0xFF1A1A1A),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4A843).withOpacity(0.15)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4A843)
                : const Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFD4A843)
                : const Color(0xFF666666),
            fontSize: 13,
            fontWeight:
            isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: const Color(0xFF1E1E1E), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFFF5F0E8), fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF666666), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Color(0xFF333333), size: 14),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        title: Text(title,
            style: const TextStyle(
                color: Color(0xFFF5F0E8), fontSize: 16)),
        content: Text(message,
            style: const TextStyle(
                color: Color(0xFF888888), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: Color(0xFF666666))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirmer',
                style: TextStyle(color: Color(0xFFE57373))),
          ),
        ],
      ),
    );
  }
}