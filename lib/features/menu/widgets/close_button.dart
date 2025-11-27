// ===========================================================================
// Widget reutilizable para botón de cerrar diálogos
// Proporciona un estilo consistente para todos los botones de cerrar
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';

class CustomCloseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isSmallScreen;
  final EdgeInsets? padding;
  final double? fontSize;

  const CustomCloseButton({
    super.key,
    this.onPressed,
    this.text = 'Cerrar',
    this.isSmallScreen = false,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.of(context).pop();
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: GameColors.textSecondary,
        backgroundColor: GameColors.secondary.withValues(alpha: 0.8),
        padding: padding ?? EdgeInsets.symmetric(
          vertical: isSmallScreen ? 12 : 16,
          horizontal: isSmallScreen ? 16 : 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: GameColors.secondary.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? (isSmallScreen ? 14 : 16),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}