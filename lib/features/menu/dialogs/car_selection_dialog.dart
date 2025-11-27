// ===========================================================================
// Este codigo define un dialogo para seleccionar el color del coche
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../widgets/car_selector.dart';
import '../widgets/close_button.dart';

/// Diálogo para seleccionar el color del coche
class CarSelectionDialog extends StatelessWidget {
  const CarSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;
    
    // Configuración del diálogo
    final dialogWidth = isSmallScreen 
        ? screenSize.width * 0.95 
        : (isMediumScreen ? screenSize.width * 0.85 : screenSize.width * 0.75);
    
    final maxDialogWidth = isSmallScreen ? 400.0 : (isMediumScreen ? 500.0 : 600.0);
    final actualWidth = dialogWidth.clamp(300.0, maxDialogWidth);
    
    return Dialog(
      backgroundColor: GameColors.hudBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: actualWidth,
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.8,
          maxWidth: maxDialogWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header responsivo
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: GameColors.surface, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car, 
                    color: GameColors.primary,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Expanded(
                    child: Text(
                      'Seleccionar Coche',
                      style: TextStyle(
                        color: GameColors.textPrimary,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido con scroll
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: CarSelector(
                  onCarSelected: (color) {
                    // El feedback ya se maneja dentro del CarSelector
                  },
                ),
              ),
            ),
            
            // Botones de acción
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: GameColors.surface, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomCloseButton(
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}