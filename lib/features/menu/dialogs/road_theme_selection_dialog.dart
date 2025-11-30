// ===========================================================================
// Diálogo para seleccionar el tema visual de la carretera
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/road_theme.dart';
import '../../../services/preferences_service.dart';
import '../widgets/close_button.dart';

/// Diálogo para seleccionar el tema de carretera
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
    final isSmallScreen = screenSize.width < 600;
    final crossAxisCount = isSmallScreen ? 2 : 3;
    final dialogWidth = screenSize.width * (isSmallScreen ? 0.9 : 0.7);
    final maxDialogWidth = isSmallScreen ? 400.0 : 600.0;
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
            // Header
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
                    Icons.landscape,
                    color: GameColors.primary,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Expanded(
                    child: Text(
                      'Tema de Carretera',
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
            
            // Grid de temas
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isSmallScreen ? 8 : 12,
                    mainAxisSpacing: isSmallScreen ? 8 : 12,
                    childAspectRatio: isSmallScreen ? 0.8 : 0.9,
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
                            width: 2,
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
                            // Previsualización del tema
                            Container(
                              width: isSmallScreen ? 60 : 80,
                              height: isSmallScreen ? 40 : 50,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                gradient: theme.roadGradient,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.roadBorderColor,
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Fondo del cielo
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: isSmallScreen ? 15 : 20,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            theme.skyGradient.colors.first,
                                            theme.skyGradient.colors.last,
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Línea central
                                  Center(
                                    child: Container(
                                      width: 2,
                                      height: isSmallScreen ? 25 : 30,
                                      decoration: BoxDecoration(
                                        color: theme.roadLineColor,
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Icono del tema
                            Icon(
                              theme.icon,
                              color: isSelected ? GameColors.primary : GameColors.textSecondary,
                              size: isSmallScreen ? 16 : 20,
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Nombre del tema
                            Text(
                              theme.name,
                              style: TextStyle(
                                color: isSelected ? GameColors.primary : GameColors.textPrimary,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            // Descripción del tema
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                theme.description,
                                style: TextStyle(
                                  color: GameColors.textSecondary,
                                  fontSize: isSmallScreen ? 9 : 10,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
            
            // Footer con botón de cerrar
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
                  CustomCloseButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}