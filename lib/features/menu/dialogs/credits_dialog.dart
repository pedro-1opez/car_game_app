// =========================================================================
// Este código define un diálogo de créditos del juego,
// mostrando información sobre el desarrollo, tecnologías y agradecimientos.
// ===========================================================================

import 'package:flutter/material.dart';
import 'dart:ui'; // Para ImageFilter
import '../widgets/close_button.dart';

// Colores consistentes con tu tema (puedes moverlos a un archivo común si prefieres)
class CreditColors {
  static const Color bgDark = Color(0xFF0F3057);
  static const Color accentGreen = Color(0xFF00E9A3);
  static const Color accentPurple = Color(0xFF9E86FF);
  static const Color textWhite = Colors.white;
}

class CreditsDialog extends StatefulWidget {
  const CreditsDialog({super.key});

  @override
  State<CreditsDialog> createState() => _CreditsDialogState();
}

class _CreditsDialogState extends State<CreditsDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Importante para el efecto vidrio
      insetPadding: const EdgeInsets.all(20),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
                decoration: BoxDecoration(
                  color: CreditColors.bgDark.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // --- HEADER ---
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: CreditColors.accentGreen, size: 28),
                              const SizedBox(width: 12),
                              const Text(
                                "CRÉDITOS",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Arial Rounded MT Bold",
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          // Botón de cerrar pequeño integrado
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- CONTENIDO SCROLLABLE ---
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildInfoCard(
                              title: "Car Slider Game",
                              icon: Icons.games_rounded,
                              color: CreditColors.accentPurple,
                              content: const Text(
                                "Versión 1.0.0",
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ),

                            const SizedBox(height: 15),

                            _buildInfoCard(
                              title: "Desarrolladores",
                              icon: Icons.code_rounded,
                              color: CreditColors.accentGreen,
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  _DevRow(name: "Figueroa Hernandez Sofia Belem", role: "Developer"),
                                  SizedBox(height: 8),
                                  _DevRow(name: "Lopez Lopez Pedro Antonio", role: "Developer"),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            _buildInfoCard(
                              title: "Tecnologías",
                              icon: Icons.build_rounded,
                              color: Colors.orangeAccent,
                              content: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: const [
                                  _TechChip(label: "Flutter"),
                                  _TechChip(label: "Dart"),
                                  _TechChip(label: "Flame Engine"),
                                  _TechChip(label: "Supabase"),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            _buildInfoCard(
                              title: "Características",
                              icon: Icons.star_rounded,
                              color: Colors.pinkAccent,
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FeatureItem("Animaciones Fluidas"),
                                  _FeatureItem("Interfaz Adaptativa"),
                                  _FeatureItem("Orientación Dual"),
                                  _FeatureItem("5 Tipos de Power-ups"),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            const Text(
                              "¡Gracias por jugar!",
                              style: TextStyle(
                                color: CreditColors.accentGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "© 2025 Car Slider Game",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: content,
          ),
        ],
      ),
    );
  }
}

class _DevRow extends StatelessWidget {
  final String name;
  final String role;
  const _DevRow({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white24,
          child: Text(name[0], style: const TextStyle(fontSize: 10, color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(role, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.pinkAccent, size: 14),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}