// ===========================================================================
// Widget para seleccionar el color/skin del coche del jugador
// ===========================================================================

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/car.dart';
import '../../../services/preferences_service.dart';

/// Widget para seleccionar el color del coche
class CarSelector extends StatefulWidget {
  final Function(CarColor)? onCarSelected;

  const CarSelector({
    super.key,
    this.onCarSelected,
  });

  @override
  State<CarSelector> createState() => _CarSelectorState();
}

class _CarSelectorState extends State<CarSelector> {
  CarColor _selectedColor = CarColor.red;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedCar();
  }

  Future<void> _loadSelectedCar() async {
    try {
      final colorName = await PreferencesService.instance.getSelectedCarColor();
      final color = CarColor.values.firstWhere(
        (c) => c.name == colorName,
        orElse: () => CarColor.red,
      );
      
      setState(() {
        _selectedColor = color;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _selectedColor = CarColor.red;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectCar(CarColor color) async {
    setState(() {
      _selectedColor = color;
    });
    
    // Guardar en preferencias
    await PreferencesService.instance.setSelectedCarColor(color.name);
    
    // Notificar cambio
    widget.onCarSelected?.call(color);
  }

  String _getColorDisplayName(CarColor color) {
    switch (color) {
      case CarColor.purple:
        return 'Morado';
      case CarColor.orange:
        return 'Naranja';
      case CarColor.blue:
        return 'Azul';
      case CarColor.red:
        return 'Rojo';
      case CarColor.green:
        return 'Verde';
      case CarColor.yellow:
        return 'Amarillo';
      case CarColor.white:
        return 'Blanco';
      case CarColor.black:
        return 'Negro';
    }
  }

  Color _getColorValue(CarColor color) {
    switch (color) {
      case CarColor.purple:
        return Colors.purple;
      case CarColor.orange:
        return Colors.orange;
      case CarColor.blue:
        return Colors.blue;
      case CarColor.red:
        return Colors.red;
      case CarColor.green:
        return Colors.green;
      case CarColor.yellow:
        return Colors.yellow;
      case CarColor.white:
        return Colors.white;
      case CarColor.black:
        return Colors.black;
    }
  }

  Widget _buildCarPreview(CarColor color, bool isSelected, Size screenSize) {
    // Cálculos basados en el tamaño de pantalla
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;
    final carWidth = isSmallScreen ? 40.0 : (isMediumScreen ? 50.0 : 60.0);
    final carHeight = isSmallScreen ? 60.0 : (isMediumScreen ? 75.0 : 90.0);
    final fontSize = isSmallScreen ? 10.0 : (isMediumScreen ? 11.0 : 12.0);
    final padding = isSmallScreen ? 4.0 : 8.0;
    final margin = isSmallScreen ? 2.0 : 4.0;
    
    return GestureDetector(
      onTap: () => _selectCar(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(margin),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: isSelected ? GameColors.primary.withOpacity(0.2) : GameColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? GameColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: GameColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Representación visual del coche
            Container(
              width: carWidth,
              height: carHeight,
              decoration: BoxDecoration(
                color: _getColorValue(color),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: GameColors.textSecondary,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Detalles del coche
                  Positioned(
                    top: carHeight * 0.1,
                    left: carWidth * 0.15,
                    right: carWidth * 0.15,
                    child: Container(
                      height: carHeight * 0.15,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: carHeight * 0.1,
                    left: carWidth * 0.15,
                    right: carWidth * 0.15,
                    child: Container(
                      height: carHeight * 0.15,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Indicador de selección
                  if (isSelected)
                    Positioned(
                      top: carHeight * 0.05,
                      right: carWidth * 0.05,
                      child: Container(
                        width: isSmallScreen ? 12 : 16,
                        height: isSmallScreen ? 12 : 16,
                        decoration: BoxDecoration(
                          color: GameColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: isSmallScreen ? 8 : 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 4 : 8),
            // Nombre del color
            Text(
              _getColorDisplayName(color),
              style: TextStyle(
                color: isSelected ? GameColors.primary : GameColors.textPrimary,
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(GameColors.primary),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;
    
    // Configuración responsiva del grid
    final crossAxisCount = isSmallScreen ? 3 : (isMediumScreen ? 4 : 4);
    final childAspectRatio = isSmallScreen ? 0.7 : (isMediumScreen ? 0.75 : 0.8);
    final containerHeight = isSmallScreen ? 220.0 : (isMediumScreen ? 250.0 : 280.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        
        // Grid de coches
        Container(
          height: containerHeight,
          decoration: BoxDecoration(
            color: GameColors.hudBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: GameColors.surface,
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              mainAxisSpacing: isSmallScreen ? 2 : 4,
              crossAxisSpacing: isSmallScreen ? 2 : 4,
              children: CarColor.values.map((color) {
                final isSelected = color == _selectedColor;
                return _buildCarPreview(color, isSelected, screenSize);
              }).toList(),
            ),
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 6 : 8),
        
        // Información del coche seleccionado
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          decoration: BoxDecoration(
            color: GameColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: GameColors.secondary,
                size: isSmallScreen ? 14 : 16,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  'Coche seleccionado: ${_getColorDisplayName(_selectedColor)}',
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}