import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/camera_service.dart';
import '../../../core/widgets/photo_viewer.dart';
import '../../../generated/app_localizations.dart';

/// Camera screen for photo capture with professional UI
class CameraScreen extends StatefulWidget {
  final String? title;
  final Function(File)? onPhotoCaptured;
  final bool allowMultiple;
  final int? maxPhotos;
  final bool autoNavigateOnCapture;

  const CameraScreen({
    super.key,
    this.title,
    this.onPhotoCaptured,
    this.allowMultiple = false,
    this.maxPhotos,
    this.autoNavigateOnCapture = true,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isInitialized = false;
  bool _isCapturing = false;
  FlashMode _currentFlashMode = FlashMode.off;
  List<File> _capturedPhotos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      print('📷 CameraScreen: Initializing camera...');
      final success = await _cameraService.initialize();
      
      if (success && mounted) {
        setState(() {
          _isInitialized = true;
        });
        print('✅ CameraScreen: Camera initialized successfully');
      } else {
        print('❌ CameraScreen: Failed to initialize camera');
        if (mounted) {
          _showErrorDialog(AppLocalizations.of(context)!.cameraInitializationFailed);
        }
      }
    } catch (e) {
      print('❌ CameraScreen: Camera initialization error: $e');
      if (mounted) {
        _showErrorDialog('Camera initialization failed: $e');
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing || !_isInitialized) return;

    // Check max photos limit
    if (widget.maxPhotos != null && _capturedPhotos.length >= widget.maxPhotos!) {
      _showErrorDialog('Maximum ${widget.maxPhotos} photos allowed');
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      print('📸 CameraScreen: Capturing photo...');
      final photoFile = await _cameraService.capturePhoto();
      
      if (photoFile != null) {
        print('✅ CameraScreen: Photo captured successfully');

        if (widget.allowMultiple) {
          _capturedPhotos.add(photoFile);
          setState(() {});
          
          // Show brief success indicator
          _showCaptureSuccess();
        } else {
          // Show preview and confirm
          final confirmed = await _showPhotoPreview(photoFile);
          if (confirmed) {
            widget.onPhotoCaptured?.call(photoFile);
            if (widget.autoNavigateOnCapture && mounted) {
              Navigator.of(context).pop(photoFile);
            }
          }
        }
      } else {
        _showErrorDialog(AppLocalizations.of(context)!.photoCaptureFailed);
      }
    } catch (e) {
      print('❌ CameraScreen: Photo capture error: $e');
      _showErrorDialog('Photo capture failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<bool> _showPhotoPreview(File photoFile) async {
    if (!mounted) return false;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PhotoViewer(
          imageFile: photoFile,
          title: AppLocalizations.of(context)!.photoPreview,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.retake),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.usePhoto),
            ),
          ],
        ),
      ),
    );

    return result ?? false;
  }

  void _showCaptureSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.photoCaptured),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (_isCapturing) return;

    try {
      final success = await _cameraService.switchCamera();
      if (!success) {
        _showErrorDialog('Failed to switch camera');
      }
    } catch (e) {
      _showErrorDialog('Camera switch failed: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (!_cameraService.hasFlash) return;

    try {
      final flashModes = _cameraService.getSupportedFlashModes();
      if (flashModes.isEmpty) return;

      // Cycle through flash modes
      final currentIndex = flashModes.indexOf(_currentFlashMode);
      final nextIndex = (currentIndex + 1) % flashModes.length;
      _currentFlashMode = flashModes[nextIndex];

      final success = await _cameraService.setFlashMode(_currentFlashMode);
      if (success) {
        setState(() {});
      }
    } catch (e) {
      _showErrorDialog('Flash toggle failed: $e');
    }
  }

  void _finishMultipleCapture() {
    if (_capturedPhotos.isNotEmpty) {
      widget.onPhotoCaptured?.call(_capturedPhotos.first);
      Navigator.of(context).pop(_capturedPhotos);
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _capturedPhotos.removeAt(index);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
      default:
        return Icons.flash_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title ?? l10n.capturePhoto),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Storage info
          IconButton(
            onPressed: () => _showStorageInfo(),
            icon: const Icon(Icons.info_outline),
            tooltip: l10n.storageInfo,
          ),
          // Finish button for multiple capture
          if (widget.allowMultiple && _capturedPhotos.isNotEmpty)
            TextButton(
              onPressed: _finishMultipleCapture,
              child: Text(
                '${l10n.done} (${_capturedPhotos.length})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_isInitialized && _cameraService.isInitialized)
            Positioned.fill(
              child: CameraPreview(_cameraService.controller!),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    l10n.initializingCamera,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

          // Camera controls overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Photo gallery for multiple capture
                  if (widget.allowMultiple && _capturedPhotos.isNotEmpty)
                    Container(
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _capturedPhotos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    _capturedPhotos[index],
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Main controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Flash button
                      if (_cameraService.hasFlash)
                        _ControlButton(
                          icon: _getFlashIcon(),
                          onPressed: _toggleFlash,
                          isActive: _currentFlashMode != FlashMode.off,
                        )
                      else
                        const SizedBox(width: 48),

                      // Capture button
                      GestureDetector(
                        onTap: _isCapturing ? null : _capturePhoto,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: _isCapturing
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                )
                              : const Icon(
                                  Icons.camera,
                                  size: 32,
                                  color: Colors.black,
                                ),
                        ),
                      ),

                      // Camera switch button
                      if (_cameraService.cameras != null && _cameraService.cameras!.length > 1)
                        _ControlButton(
                          icon: Icons.cameraswitch,
                          onPressed: _switchCamera,
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStorageInfo() async {
    final storageInfo = await _cameraService.getStorageInfo();
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.storageInfo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context)!.totalSize}: ${_formatBytes(storageInfo['totalSize'])}'),
            Text('${AppLocalizations.of(context)!.photoCount}: ${storageInfo['fileCount']}'),
            const SizedBox(height: 16),
            if (storageInfo['fileCount'] > 0)
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final deletedCount = await _cameraService.cleanupOldPhotos(olderThanDays: 30);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cleaned up $deletedCount old photos')),
                    );
                  }
                },
                child: const Text('Clean up old photos'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.blue : Colors.black54,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}