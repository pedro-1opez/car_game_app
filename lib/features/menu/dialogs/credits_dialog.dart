// =========================================================================
// Este código define un diálogo de créditos del juego,
// mostrando información sobre el desarrollo, tecnologías y agradecimientos.
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Diálogo de créditos del juego
class CreditsDialog extends StatelessWidget {
  const CreditsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: GameColors.hudBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.info, color: GameColors.primary),
          const SizedBox(width: 8),
          Text(
            'Créditos',
            style: TextStyle(color: GameColors.textPrimary),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del juego
            _buildCreditSection(
              title: '🎮 Car Slider Game',
              items: [
                'Versión: 1.0.0',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Desarrollo
            _buildCreditSection(
              title: '👨‍💻 Desarrolladores',
              items: [
                'Figueroa Hernandez Sofia Belem',
                'Lopez Lopez Pedro Antonio',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tecnologías
            _buildCreditSection(
              title: '🛠️ Tecnologías Utilizadas',
              items: [
                'Lenguaje: Dart',
                'Framework: Flutter',
                'Motor: Flame Game Engine',
                'Base de datos: Supabase',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Características
            _buildCreditSection(
              title: '✨ Características',
              items: [
                '• Animaciones',
                '• Interfaz adaptativa',
                '• Orientacion Dual',                
                '• 5 tipos de power-ups',
                '• Sistema de puntuaciones',
                '• 2 modos de juego (niveles / infinito)',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Agradecimientos
            Text(
              '💝 Agradecimientos',
              style: TextStyle(
                color: GameColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esperamos que disfrutes jugando tanto como nosotros disfrutamos desarrollándolo. Cualquier problema o sugerencia, no dudes en contactarnos.',
              style: TextStyle(
                color: GameColors.textSecondary,
                fontSize: 12,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Footer
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GameColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '© 2025 Car Slider Game',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildCreditSection({
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: GameColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            item,
            style: TextStyle(
              color: GameColors.textSecondary,
              fontSize: 12,
            ),
          ),
        )),
      ],
    );
  }
}