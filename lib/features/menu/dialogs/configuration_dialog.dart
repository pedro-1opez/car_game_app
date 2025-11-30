// ===========================================================================
// Este código define un diálogo de configuración del juego,
// permitiendo a los jugadores seleccionar la orientación y otras opciones.
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_orientation.dart';
import '../../game/game_exports.dart';
import 'car_selection_dialog.dart';
import 'road_theme_selection_dialog.dart';
import '../../../services/preferences_service.dart';
import '../widgets/close_button.dart';

/// Diálogo de configuración del juego
class ConfigurationDialog extends StatefulWidget {
  final Function(GameController, GameOrientation?) onStartGame;

  const ConfigurationDialog({
    super.key,
    required this.onStartGame,
  });

  @override
  State<ConfigurationDialog> createState() => _ConfigurationDialogState();
}

class _ConfigurationDialogState extends State<ConfigurationDialog> {
  GameOrientation _selectedOrientation = GameOrientation.vertical;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final orientation = await PreferencesService.instance.getPreferredOrientation();
      final sound = await PreferencesService.instance.isSoundEnabled();
      // Note: vibration preferences would need to be added to PreferencesService
      
      setState(() {
        _selectedOrientation = orientation;
        _soundEnabled = sound;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveOrientationPreference(GameOrientation orientation) async {
    await PreferencesService.instance.savePreferredOrientation(orientation);
    setState(() {
      _selectedOrientation = orientation;
    });
  }

  Future<void> _saveSoundPreference(bool enabled) async {
    await PreferencesService.instance.setSoundEnabled(enabled);
    setState(() {
      _soundEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AlertDialog(
        backgroundColor: GameColors.hudBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(GameColors.primary),
          ),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600 || screenSize.height < 700;
    final isTablet = screenSize.width > 600;
    final dialogWidth = screenSize.width * (isSmallScreen ? 0.95 : 0.8);
    final maxDialogWidth = isTablet ? 500.0 : 400.0;
    final actualWidth = dialogWidth.clamp(300.0, maxDialogWidth);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: actualWidth,
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.9,
          maxWidth: maxDialogWidth,
        ),
        decoration: BoxDecoration(
          color: GameColors.hudBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header fijo
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: GameColors.surface,
                    width: 1,
                  ),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: GameColors.primary,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Configuración',
                      style: TextStyle(
                        color: GameColors.textPrimary,
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido con scroll
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: _buildScrollableContent(context, isSmallScreen, isTablet),
              ),
            ),
            
            // Footer fijo
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: GameColors.surface,
                    width: 1,
                  ),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomCloseButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context, bool isSmallScreen, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección de Orientación
        _buildOrientationSection(isSmallScreen),
        
        // Sección de Selección de Coche
        _buildSelectionSection(
          'Seleccionar Coche',
          'Cambia el color de tu coche',
          Icons.directions_car,
          () => showDialog(
            context: context,
            builder: (context) => const CarSelectionDialog(),
          ),
          isSmallScreen,
        ),
        
        // Sección de Tema de Carretera
        _buildSelectionSection(
          'Tema de Carretera',
          'Cambia el aspecto visual de la carretera',
          Icons.landscape,
          () => showDialog(
            context: context,
            builder: (context) => const RoadThemeSelectionDialog(),
          ),
          isSmallScreen,
        ),
        
        // Sección de Sonido
        _buildSwitchSection(
          'Sonido',
          'Efectos de sonido del juego',
          Icons.volume_up,
          _soundEnabled,
          _saveSoundPreference,
          isSmallScreen,
        ),
        
        // Sección de Vibración
        _buildSwitchSection(
          'Vibración',
          'Feedback háptico durante el juego',
          Icons.vibration,
          _vibrationEnabled,
          (value) {
            setState(() {
              _vibrationEnabled = value;
            });
            // TODO: Implementar guardado de vibración en PreferencesService
          },
          isSmallScreen,
        ),
        
        // Espaciado final para scroll suave
        SizedBox(height: isSmallScreen ? 16 : 20),
      ],
    );
  }

  Widget _buildOrientationSection(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GameColors.hudBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header de sección
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: GameColors.hudBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.screen_rotation,
                  color: GameColors.secondary,
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orientación del Juego',
                        style: TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Selecciona la orientación preferida',
                        style: TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido de la sección
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              children: [
                _buildOrientationButton(
                  GameOrientation.vertical,
                  Icons.stay_current_portrait,
                  'Vertical',
                  isSmallScreen,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                _buildOrientationButton(
                  GameOrientation.horizontal,
                  Icons.screen_rotation,
                  'Horizontal',
                  isSmallScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrientationButton(GameOrientation orientation, IconData icon, String label, bool isSmallScreen) {
    final isSelected = _selectedOrientation == orientation;
    
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 44 : 48,
      child: ElevatedButton.icon(
        onPressed: () => _saveOrientationPreference(orientation),
        icon: Icon(icon, size: isSmallScreen ? 16 : 18),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? GameColors.primary : GameColors.background,
          foregroundColor: isSelected ? Colors.white : GameColors.textPrimary,
          elevation: isSelected ? 4 : 1,
          shadowColor: isSelected ? GameColors.primary.withValues(alpha: 0.4) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? GameColors.primary : GameColors.hudBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionSection(String title, String subtitle, IconData icon, VoidCallback onTap, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GameColors.hudBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: GameColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: GameColors.secondary,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: GameColors.textSecondary,
                  size: isSmallScreen ? 18 : 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchSection(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GameColors.hudBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: value 
                    ? GameColors.primary.withValues(alpha: 0.1)
                    : GameColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: value ? GameColors.primary : GameColors.secondary,
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: isSmallScreen ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: GameColors.primary,
              activeTrackColor: GameColors.primary.withValues(alpha: 0.3),
              inactiveThumbColor: GameColors.textSecondary,
              inactiveTrackColor: GameColors.hudBorder,
            ),
          ],
        ),
      ),
    );
  }
}