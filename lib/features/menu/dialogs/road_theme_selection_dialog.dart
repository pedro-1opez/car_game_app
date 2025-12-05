// ===========================================================================
// Diálogo para seleccionar el tema visual de la carretera
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/road_theme.dart';
import '../../../services/preferences_service.dart';
import '../widgets/close_button.dart';

class RoadThemeSelectionDialog extends StatefulWidget {
  const RoadThemeSelectionDialog({super.key});

  @override
  State<RoadThemeSelectionDialog> createState() => _RoadThemeSelectionDialogState();
}

class _RoadThemeSelectionDialogState extends State<RoadThemeSelectionDialog> {
  RoadThemeType _selectedTheme = RoadThemeType.classic;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
  }

  Future<void> _loadCurrentTheme() async {
    try {
      final currentTheme = await PreferencesService.instance.getSelectedRoadTheme();
      setState(() {
        _selectedTheme = currentTheme;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTheme(RoadThemeType theme) async {
    await PreferencesService.instance.setSelectedRoadTheme(theme);
    setState(() {
      _selectedTheme = theme;
    });
    // Opcional: Cerrar diálogo automáticamente al seleccionar
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final crossAxisCount = isSmallScreen ? 2 : 3;
    final dialogWidth = screenSize.width * (isSmallScreen ? 0.9 : 0.7);
    final maxDialogWidth = isSmallScreen ? 400.0 : 600.0;
    final actualWidth = dialogWidth.clamp(300.0, maxDialogWidth);

    return Dialog(
      backgroundColor: GameColors.hudBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: actualWidth,
        constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.8, maxWidth: maxDialogWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: GameColors.surface, width: 1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.landscape, color: GameColors.primary, size: isSmallScreen ? 20 : 24),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Expanded(
                    child: Text(
                      'Elige tu Carretera',
                      style: TextStyle(
                        color: GameColors.textPrimary,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Grid de Temas
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isSmallScreen ? 8 : 12,
                    mainAxisSpacing: isSmallScreen ? 8 : 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: RoadTheme.availableThemes.length,
                  itemBuilder: (context, index) {
                    final theme = RoadTheme.availableThemes[index];
                    final isSelected = _selectedTheme == theme.type;

                    return GestureDetector(
                      onTap: () => _selectTheme(theme.type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? GameColors.primary.withValues(alpha: 0.2)
                              : GameColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? GameColors.primary : Colors.transparent,
                            width: 3, // Borde un poco más grueso para que se note
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: GameColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // === AQUÍ ESTÁ EL CAMBIO PRINCIPAL: PREVISUALIZACIÓN DE IMAGEN ===
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: GameColors.hudBorder),
                                  // Imagen de fondo (Preview)
                                  image: DecorationImage(
                                    image: AssetImage(theme.assetPath), // Usamos la ruta del asset
                                    fit: BoxFit.cover, // Para que llene el cuadrito
                                    alignment: Alignment.center,
                                  ),
                                ),
                                // Overlay opcional para que el texto resalte si la imagen es clara
                                child: isSelected
                                    ? Container(color: Colors.transparent)
                                    : Container(color: Colors.black.withValues(alpha: 0.2)),
                              ),
                            ),

                            // Nombre del tema
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                theme.name,
                                style: TextStyle(
                                  color: isSelected ? GameColors.primary : GameColors.textPrimary,
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: GameColors.surface, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [CustomCloseButton()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}