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
                'Desarrollado con Flutter',
                'Motor de juego: Flame Engine',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Desarrollo
            _buildCreditSection(
              title: '👨‍💻 Desarrollo',
              items: [
                'Desarrollador Principal: Tu Nombre',
                'Diseño de Juego: Equipo de Diseño',
                'Programación: Flutter & Dart',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tecnologías
            _buildCreditSection(
              title: '🛠️ Tecnologías Utilizadas',
              items: [
                'Flutter SDK',
                'Flame Game Engine',
                'Supabase Backend',
                'Provider State Management',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Características
            _buildCreditSection(
              title: '✨ Características',
              items: [
                '• Dual orientación adaptativa',
                '• Sistema de colisiones avanzado',
                '• 6 tipos de power-ups',
                '• Animaciones fluidas',
                '• Sistema de puntuaciones',
                '• Interfaz adaptativa',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Agradecimientos
            Text(
              '💝 Agradecimientos Especiales',
              style: TextStyle(
                color: GameColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gracias a todos los jugadores que hacen posible este proyecto. ¡Esperamos que disfrutes jugando tanto como nosotros disfrutamos desarrollándolo!',
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
                  '© 2024 Car Slider Game\nHecho con ❤️ y Flutter',
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