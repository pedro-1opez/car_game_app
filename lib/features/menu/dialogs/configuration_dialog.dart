// ===========================================================================
// Este código define un diálogo de configuración del juego,
// permitiendo a los jugadores seleccionar la orientación y otras opciones.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import 'dart:ui'; // Para ImageFilter
import '../../../core/constants/colors.dart';
import '../../../core/models/game_orientation.dart';
import '../../game/game_exports.dart';
import 'car_selection_dialog.dart';
import 'road_theme_selection_dialog.dart';
import '../../../services/preferences_service.dart';

// Definimos estilos locales
class ConfigStyles {
  static const Color bgDark = Color(0xFF0F3057);
  static const Color primary = Color(0xFF07B684);
  static const Color cardBg = Color(0xFF162447); // Un poco más claro que el fondo
}

class ConfigurationDialog extends StatefulWidget {
  final Function(GameController, GameOrientation?) onStartGame;

  const ConfigurationDialog({
    super.key,
    required this.onStartGame,
  });

  @override
  State<ConfigurationDialog> createState() => _ConfigurationDialogState();
}

class _ConfigurationDialogState extends State<ConfigurationDialog> with SingleTickerProviderStateMixin {
  GameOrientation _selectedOrientation = GameOrientation.vertical;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> _localMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // Animación
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);

    _loadPreferences().then((_) => _animController.forward());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final orientation = await PreferencesService.instance.getPreferredOrientation();
      final sound = await PreferencesService.instance.isSoundEnabled();
      final playerName = await PreferencesService.instance.getPlayerName();

      if (mounted) {
        setState(() {
          _selectedOrientation = orientation;
          _soundEnabled = sound;
          _nameController.text = playerName;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOrientationPreference(GameOrientation orientation) async {
    HapticFeedback.selectionClick();
    await PreferencesService.instance.savePreferredOrientation(orientation);
    setState(() => _selectedOrientation = orientation);
  }

  Future<void> _saveSoundPreference(bool enabled) async {
    HapticFeedback.lightImpact();
    await PreferencesService.instance.setSoundEnabled(enabled);
    setState(() => _soundEnabled = enabled);
  }

  Future<void> _savePlayerName(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      await PreferencesService.instance.savePlayerName(trimmedName);
      if (mounted) {
        _localMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: const Text('¡Nombre guardado!', style: TextStyle(color: ConfigStyles.bgDark, fontWeight: FontWeight.bold)),
            backgroundColor: ConfigStyles.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ConfigStyles.primary));
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450, maxHeight: 750),
              decoration: BoxDecoration(
                color: ConfigStyles.bgDark.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30, offset: const Offset(0, 10)),
                ],
              ),
              child: ScaffoldMessenger(
                key: _localMessengerKey,
                child: Scaffold(
                  backgroundColor: Colors.transparent, // Transparente para ver el contenedor
                  resizeToAvoidBottomInset: false,
                  body: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- HEADER ---
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(Icons.settings_suggest_rounded, color: ConfigStyles.primary, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              "CONFIGURACIÓN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontFamily: "Arial Rounded MT Bold",
                              ),
                            ),
                            const Spacer(),
                            _buildCloseButton(context),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white12),

                      // --- BODY ---
                      Flexible(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          children: [
                            _sectionTitle("PERFIL"),
                            _buildNameInput(),

                            const SizedBox(height: 25),
                            _sectionTitle("JUEGO"),
                            _buildOrientationSelector(),

                            const SizedBox(height: 15),
                            // Botones grandes de selección
                            Row(
                              children: [
                                Expanded(
                                  child: _buildBigOptionButton(
                                    icon: Icons.directions_car_filled_rounded,
                                    label: "Coche",
                                    color: Colors.orangeAccent,
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (c) => const CarSelectionDialog(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildBigOptionButton(
                                    icon: Icons.landscape_rounded,
                                    label: "Mapa",
                                    color: Colors.purpleAccent,
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (c) => const RoadThemeSelectionDialog(),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),
                            _sectionTitle("SISTEMA"),
                            _buildSwitchTile(
                                "Sonido",
                                Icons.volume_up_rounded,
                                _soundEnabled,
                                _saveSoundPreference
                            ),
                            const SizedBox(height: 10),
                            _buildSwitchTile(
                                "Vibración",
                                Icons.vibration_rounded,
                                _vibrationEnabled,
                                    (val) {
                                  HapticFeedback.lightImpact();
                                  setState(() => _vibrationEnabled = val);
                                  // TODO: Guardar en preferences si es necesario
                                }
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _nameController,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.person_outline_rounded, color: Colors.white.withOpacity(0.5)),
          hintText: "Tu Nombre",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.check_circle, color: ConfigStyles.primary),
            onPressed: () {
              _savePlayerName(_nameController.text);
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        onSubmitted: (val) => _savePlayerName(val),
      ),
    );
  }

  Widget _buildOrientationSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _orientationOption(GameOrientation.vertical, Icons.stay_current_portrait_rounded, "Vertical")),
          Expanded(child: _orientationOption(GameOrientation.horizontal, Icons.stay_current_landscape_rounded, "Horizontal")),
        ],
      ),
    );
  }

  Widget _orientationOption(GameOrientation orientation, IconData icon, String label) {
    final isSelected = _selectedOrientation == orientation;
    return GestureDetector(
      onTap: () => _saveOrientationPreference(orientation),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ConfigStyles.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: ConfigStyles.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          children: [
            Icon(
                icon,
                color: isSelected ? ConfigStyles.bgDark : Colors.white.withOpacity(0.5),
                size: 20
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? ConfigStyles.bgDark : Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? ConfigStyles.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: value ? ConfigStyles.primary : Colors.white.withOpacity(0.5), size: 18),
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ConfigStyles.primary,
            activeTrackColor: ConfigStyles.primary.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}