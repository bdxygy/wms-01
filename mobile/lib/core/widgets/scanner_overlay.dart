import 'package:flutter/material.dart';

/// Custom scanner overlay widget with scanning frame and controls
class ScannerOverlay extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onFlashToggle;
  final VoidCallback? onCameraSwitch;
  final VoidCallback? onManualEntry;
  final VoidCallback? onClose;
  final bool isFlashOn;
  final bool canSwitchCamera;
  final double scanAreaSize;
  final Color scanAreaColor;
  final double scanAreaOpacity;

  const ScannerOverlay({
    super.key,
    this.title,
    this.subtitle,
    this.onFlashToggle,
    this.onCameraSwitch,
    this.onManualEntry,
    this.onClose,
    this.isFlashOn = false,
    this.canSwitchCamera = true,
    this.scanAreaSize = 300.0,
    this.scanAreaColor = Colors.white,
    this.scanAreaOpacity = 0.8,
  });

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));

    _scanLineController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay with transparent scanning area
        _buildOverlay(),
        
        // Scanning frame
        _buildScanningFrame(),
        
        // Animated scan line
        _buildScanLine(),
        
        // Top controls and title
        _buildTopSection(),
        
        // Bottom controls
        _buildBottomControls(),
        
        // Corner decorations
        _buildCornerDecorations(),
      ],
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          width: widget.scanAreaSize,
          height: widget.scanAreaSize,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: widget.scanAreaColor.withValues(alpha: widget.scanAreaOpacity),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildScanningFrame() {
    return Center(
      child: Container(
        width: widget.scanAreaSize,
        height: widget.scanAreaSize,
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.scanAreaColor.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildScanLine() {
    return Center(
      child: SizedBox(
        width: widget.scanAreaSize - 4,
        height: widget.scanAreaSize - 4,
        child: AnimatedBuilder(
          animation: _scanLineAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: ScanLinePainter(
                progress: _scanLineAnimation.value,
                color: widget.scanAreaColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          children: [
            // Close button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title ?? 'Scan Barcode',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for close button
                ],
              ),
            ),
            
            // Subtitle/instructions
            if (widget.subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  widget.subtitle!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Manual entry button
              if (widget.onManualEntry != null)
                _buildControlButton(
                  icon: Icons.keyboard,
                  label: 'Manual',
                  onPressed: widget.onManualEntry!,
                ),
              
              // Flash toggle button
              if (widget.onFlashToggle != null)
                _buildControlButton(
                  icon: widget.isFlashOn ? Icons.flash_on : Icons.flash_off,
                  label: 'Flash',
                  onPressed: widget.onFlashToggle!,
                  isActive: widget.isFlashOn,
                ),
              
              // Camera switch button
              if (widget.onCameraSwitch != null && widget.canSwitchCamera)
                _buildControlButton(
                  icon: Icons.cameraswitch,
                  label: 'Switch',
                  onPressed: widget.onCameraSwitch!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive 
                ? widget.scanAreaColor.withValues(alpha: 0.8)
                : Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCornerDecorations() {
    return Center(
      child: SizedBox(
        width: widget.scanAreaSize,
        height: widget.scanAreaSize,
        child: CustomPaint(
          painter: CornerDecoratorPainter(
            color: widget.scanAreaColor,
            cornerLength: 24,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the animated scan line
class ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanLinePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        color.withValues(alpha: 0.8),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, 2);
    paint.shader = gradient.createShader(rect);

    final y = size.height * progress;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Custom painter for corner decorations
class CornerDecoratorPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  CornerDecoratorPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      const Offset(0, 0),
      Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, cornerLength),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - cornerLength),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CornerDecoratorPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.cornerLength != cornerLength ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}