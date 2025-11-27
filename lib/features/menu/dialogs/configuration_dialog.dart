// ===========================================================================
// Este código define un diálogo de configuración del juego,
// permitiendo a los jugadores seleccionar la orientación y otras opciones.
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_orientation.dart';
import '../../game/game_exports.dart';
import 'car_selection_dialog.dart';
import '../../../services/preferences_service.dart';

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
    return AlertDialog(
      backgroundColor: GameColors.hudBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.settings, color: GameColors.primary),
          const SizedBox(width: 8),
          Text(
            'Configuración',
            style: TextStyle(color: GameColors.textPrimary),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selector de orientación
          Builder(
            builder: (context) {
              final screenSize = MediaQuery.of(context).size;
              final isSmallScreen = screenSize.width < 600;
              final titleFontSize = isSmallScreen ? 14.0 : 16.0;
              final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
              final iconSize = isSmallScreen ? 20.0 : 24.0;
              
              return ListTile(
                leading: Icon(
                  Icons.screen_rotation, 
                  color: GameColors.secondary,
                  size: iconSize,
                ),
                title: Text(
                  'Orientación del Juego',
                  style: TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Selecciona la orientación preferida',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: subtitleFontSize,
                  ),
                ),
              );
            }
          ),
          
          Builder(
            builder: (context) {
              final screenSize = MediaQuery.of(context).size;
              final isSmallScreen = screenSize.width < 600;
              
              // Configuración responsiva
              final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
              final buttonSpacing = isSmallScreen ? 6.0 : 8.0;
              final buttonHeight = isSmallScreen ? 40.0 : 48.0;
              final iconSize = isSmallScreen ? 18.0 : 20.0;
              final fontSize = isSmallScreen ? 12.0 : 14.0;
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: isSmallScreen ? 
                  // Layout vertical para pantallas pequeñas
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: buttonHeight,
                        child: ElevatedButton.icon(
                          onPressed: () => _saveOrientationPreference(GameOrientation.vertical),
                          icon: Icon(Icons.stay_current_portrait, size: iconSize),
                          label: Text(
                            'Vertical', 
                            style: TextStyle(fontSize: fontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedOrientation == GameOrientation.vertical 
                                ? GameColors.primary 
                                : GameColors.surface,
                            foregroundColor: _selectedOrientation == GameOrientation.vertical
                                ? Colors.white
                                : GameColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: buttonSpacing),
                      SizedBox(
                        height: buttonHeight,
                        child: ElevatedButton.icon(
                          onPressed: () => _saveOrientationPreference(GameOrientation.horizontal),
                          icon: Icon(Icons.screen_rotation, size: iconSize),
                          label: Text(
                            'Horizontal',
                            style: TextStyle(fontSize: fontSize),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedOrientation == GameOrientation.horizontal 
                                ? GameColors.primary 
                                : GameColors.surface,
                            foregroundColor: _selectedOrientation == GameOrientation.horizontal
                                ? Colors.white
                                : GameColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ) :
                  // Layout horizontal para pantallas medianas y grandes
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton.icon(
                            onPressed: () => _saveOrientationPreference(GameOrientation.vertical),
                            icon: Icon(Icons.stay_current_portrait, size: iconSize),
                            label: Text(
                              'Vertical',
                              style: TextStyle(fontSize: fontSize),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedOrientation == GameOrientation.vertical 
                                  ? GameColors.primary 
                                  : GameColors.surface,
                              foregroundColor: _selectedOrientation == GameOrientation.vertical
                                  ? Colors.white
                                  : GameColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: buttonSpacing),
                      Expanded(
                        child: SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton.icon(
                            onPressed: () => _saveOrientationPreference(GameOrientation.horizontal),
                            icon: Icon(Icons.screen_rotation, size: iconSize),
                            label: Text(
                              'Horizontal',
                              style: TextStyle(fontSize: fontSize),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedOrientation == GameOrientation.horizontal 
                                  ? GameColors.primary 
                                  : GameColors.surface,
                              foregroundColor: _selectedOrientation == GameOrientation.horizontal
                                  ? Colors.white
                                  : GameColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              );
            }
          ),
          
          const SizedBox(height: 20),
          
          // Selector de coche (responsivo)
          const Divider(color: GameColors.surface),
          Builder(
            builder: (context) {
              final screenSize = MediaQuery.of(context).size;
              final isSmallScreen = screenSize.width < 600;
              final titleFontSize = isSmallScreen ? 14.0 : 16.0;
              final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
              final iconSize = isSmallScreen ? 20.0 : 24.0;
              final verticalPadding = isSmallScreen ? 12.0 : 16.0;
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                child: ListTile(
                  leading: Icon(
                    Icons.directions_car, 
                    color: GameColors.secondary,
                    size: iconSize,
                  ),
                  title: Text(
                    'Seleccionar Coche',
                    style: TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Cambia el color de tu coche',
                    style: TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: subtitleFontSize,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right, 
                    color: GameColors.secondary,
                    size: iconSize,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CarSelectionDialog(),
                    );
                  },
                ),
              );
            }
          ),
          
          // Sección de Sonido (responsiva)
          Builder(
            builder: (context) {
              final screenSize = MediaQuery.of(context).size;
              final isSmallScreen = screenSize.width < 600;
              final titleFontSize = isSmallScreen ? 14.0 : 16.0;
              final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
              final iconSize = isSmallScreen ? 20.0 : 24.0;
              final verticalPadding = isSmallScreen ? 8.0 : 12.0;
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                child: ListTile(
                  leading: Icon(
                    Icons.volume_up, 
                    color: GameColors.secondary,
                    size: iconSize,
                  ),
                  title: Text(
                    'Sonido',
                    style: TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Efectos de sonido del juego',
                    style: TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: subtitleFontSize,
                    ),
                  ),
                  trailing: Switch(
                    value: _soundEnabled,
                    onChanged: _saveSoundPreference,
                    activeThumbColor: GameColors.primary,
                    activeTrackColor: GameColors.primary.withValues(alpha: 0.3),
                  ),
                ),
              );
            }
          ),
          
          // Sección de Vibración (responsiva)
          Builder(
            builder: (context) {
              final screenSize = MediaQuery.of(context).size;
              final isSmallScreen = screenSize.width < 600;
              final titleFontSize = isSmallScreen ? 14.0 : 16.0;
              final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
              final iconSize = isSmallScreen ? 20.0 : 24.0;
              final verticalPadding = isSmallScreen ? 8.0 : 12.0;
              
              return Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                child: ListTile(
                  leading: Icon(
                    Icons.vibration, 
                    color: GameColors.secondary,
                    size: iconSize,
                  ),
                  title: Text(
                    'Vibración',
                    style: TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Feedback háptico',
                    style: TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: subtitleFontSize,
                    ),
                  ),
                  trailing: Switch(
                    value: _vibrationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                      // TODO: Implementar guardado de vibración en PreferencesService
                    },
                    activeThumbColor: GameColors.primary,
                    activeTrackColor: GameColors.primary.withValues(alpha: 0.3),
                  ),
                ),
              );
            }
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cerrar',
            style: TextStyle(color: GameColors.primary),
          ),
        ),
      ],
    );
  }
}