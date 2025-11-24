// ===========================================================================
// Este código define un diálogo de configuración del juego,
// permitiendo a los jugadores seleccionar la orientación y otras opciones.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_orientation.dart';
import '../../game/game_exports.dart';

/// Diálogo de configuración del juego
class ConfigurationDialog extends StatelessWidget {
  final Function(GameController, GameOrientation?) onStartGame;

  const ConfigurationDialog({
    super.key,
    required this.onStartGame,
  });

  @override
  Widget build(BuildContext context) {
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
          ListTile(
            leading: const Icon(Icons.screen_rotation, color: GameColors.secondary),
            title: Text(
              'Orientación del Juego',
              style: TextStyle(color: GameColors.textPrimary),
            ),
            subtitle: Text(
              'Selecciona la orientación preferida',
              style: TextStyle(color: GameColors.textSecondary),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onStartGame(
                        Provider.of<GameController>(context, listen: false),
                        GameOrientation.vertical,
                      );
                    },
                    icon: const Icon(Icons.stay_current_portrait),
                    label: const Text('Vertical'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameColors.surface,
                      foregroundColor: GameColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onStartGame(
                        Provider.of<GameController>(context, listen: false),
                        GameOrientation.horizontal,
                      );
                    },
                    icon: const Icon(Icons.screen_rotation),
                    label: const Text('Horizontal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameColors.surface,
                      foregroundColor: GameColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Otras configuraciones futuras
          ListTile(
            leading: const Icon(Icons.volume_up, color: GameColors.secondary),
            title: Text(
              'Sonido',
              style: TextStyle(color: GameColors.textPrimary),
            ),
            subtitle: Text(
              'Próximamente...',
              style: TextStyle(color: GameColors.textSecondary),
            ),
            trailing: Switch(
              value: true,
              onChanged: null, // Deshabilitado por ahora
              activeThumbColor: GameColors.primary,
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.vibration, color: GameColors.secondary),
            title: Text(
              'Vibración',
              style: TextStyle(color: GameColors.textPrimary),
            ),
            subtitle: Text(
              'Feedback háptico',
              style: TextStyle(color: GameColors.textSecondary),
            ),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implementar configuración de vibración
              },
              activeThumbColor: GameColors.primary,
            ),
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