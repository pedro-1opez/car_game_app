// ==============================================================================
// El siguiente código define un widget de indicador de combustible con
// animaciones para alertar al jugador cuando el nivel de combustible es crítico
// ==============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

/// Widget que muestra el nivel de combustible del jugador
class FuelGauge extends StatefulWidget {
  final double fuelLevel; // 0.0 a 1.0
  final bool isCritical;
  final bool showLabel;
  
  const FuelGauge({
    super.key,
    required this.fuelLevel,
    required this.isCritical,
    this.showLabel = true,
  });
  
  @override
  State<FuelGauge> createState() => _FuelGaugeState();
}

class _FuelGaugeState extends State<FuelGauge>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void didUpdateWidget(FuelGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animar cuando el combustible está crítico
    if (widget.isCritical && !oldWidget.isCritical) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isCritical && oldWidget.isCritical) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.hudBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: GameColors.hudBorder,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.showLabel) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_gas_station,
                  color: GameColors.fuelBlue,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Combustible',
                    style: TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
          ],
          
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isCritical ? _pulseAnimation.value : 1.0,
                    child: _buildFuelBar(),
                  );
                },
              ),
            ),
          ),
          
          if (widget.showLabel) ...[
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${(widget.fuelLevel * 100).round()}%',
                style: TextStyle(
                  color: GameColors.getFuelColor(widget.fuelLevel),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildFuelBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        return Container(
          width: availableWidth,
          height: 8,
          decoration: BoxDecoration(
            color: GameColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: GameColors.hudBorder,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                // Fondo de la barra
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: GameColors.surfaceLight.withValues(alpha: 0.3),
                ),
                
                // Barra de combustible
                FractionallySizedBox(
                  widthFactor: widget.fuelLevel.clamp(0.0, 1.0),
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          GameColors.getFuelColor(widget.fuelLevel),
                          GameColors.getFuelColor(widget.fuelLevel).withValues(alpha: 0.7),
                        ],
                      ),
                ),
              ),
            ),
            
            // Efecto de brillo
            if (widget.fuelLevel > 0.1)
              Positioned(
                left: 2,
                top: 1,
                right: 2,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.6),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            
            // Indicador de nivel crítico
            if (widget.isCritical)
              Positioned(
                right: 2,
                top: 2,
                child: Icon(
                  Icons.warning,
                  color: GameColors.error,
                  size: 8,
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}