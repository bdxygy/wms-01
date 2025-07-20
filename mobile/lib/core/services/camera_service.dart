import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/image_utils.dart';

/// Service for managing camera functionality and photo capture
class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  List<CameraDescription>? _cameras;
  CameraController? _controller;
  bool _isInitialized = false;
  int _currentCameraIndex = 0;

  /// Available cameras
  List<CameraDescription>? get cameras => _cameras;

  /// Current camera controller
  CameraController? get controller => _controller;

  /// Whether the camera service is initialized
  bool get isInitialized => _isInitialized && _controller?.value.isInitialized == true;

  /// Current camera description
  CameraDescription? get currentCamera => 
      _cameras != null && _currentCameraIndex < _cameras!.length 
          ? _cameras![_currentCameraIndex] 
          : null;

  /// Initialize camera service
  Future<bool> initialize() async {
    try {
      print('📷 CameraService: Initializing camera service...');
      
      // Check camera permission
      final permissionStatus = await _checkCameraPermission();
      if (!permissionStatus) {
        print('❌ CameraService: Camera permission denied');
        return false;
      }

      // Get available cameras
      _cameras = await availableCameras();
      print('📷 CameraService: Found ${_cameras?.length ?? 0} cameras');

      if (_cameras == null || _cameras!.isEmpty) {
        print('❌ CameraService: No cameras available');
        return false;
      }

      // Initialize with rear camera (or first available)
      _currentCameraIndex = _findRearCameraIndex();
      await _initializeController();

      _isInitialized = true;
      print('✅ CameraService: Camera service initialized successfully');
      return true;
    } catch (e) {
      print('❌ CameraService: Failed to initialize camera service: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Check and request camera permission
  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    return false;
  }

  /// Find rear camera index (prefer rear camera for product photos)
  int _findRearCameraIndex() {
    if (_cameras == null) return 0;
    
    for (int i = 0; i < _cameras!.length; i++) {
      if (_cameras![i].lensDirection == CameraLensDirection.back) {
        return i;
      }
    }
    return 0; // Default to first camera if no rear camera found
  }

  /// Initialize camera controller
  Future<void> _initializeController() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    // Dispose existing controller
    await _controller?.dispose();

    // Create new controller with high resolution
    _controller = CameraController(
      _cameras![_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    print('✅ CameraService: Camera controller initialized');
  }

  /// Switch between front and back cameras
  Future<bool> switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) {
      print('⚠️ CameraService: Cannot switch camera - insufficient cameras');
      return false;
    }

    try {
      print('🔄 CameraService: Switching camera...');
      
      // Find next camera (toggle between front and back)
      final currentDirection = _cameras![_currentCameraIndex].lensDirection;
      final targetDirection = currentDirection == CameraLensDirection.back 
          ? CameraLensDirection.front 
          : CameraLensDirection.back;

      int newIndex = -1;
      for (int i = 0; i < _cameras!.length; i++) {
        if (_cameras![i].lensDirection == targetDirection) {
          newIndex = i;
          break;
        }
      }

      if (newIndex == -1) {
        print('⚠️ CameraService: Target camera direction not found');
        return false;
      }

      _currentCameraIndex = newIndex;
      await _initializeController();
      
      print('✅ CameraService: Camera switched successfully');
      return true;
    } catch (e) {
      print('❌ CameraService: Failed to switch camera: $e');
      return false;
    }
  }

  /// Set flash mode
  Future<bool> setFlashMode(FlashMode flashMode) async {
    if (!isInitialized) return false;

    try {
      await _controller!.setFlashMode(flashMode);
      print('✅ CameraService: Flash mode set to $flashMode');
      return true;
    } catch (e) {
      print('❌ CameraService: Failed to set flash mode: $e');
      return false;
    }
  }

  /// Capture photo
  Future<File?> capturePhoto({
    String? customName,
    bool compress = true,
    int quality = 85,
  }) async {
    if (!isInitialized) {
      print('❌ CameraService: Camera not initialized');
      return null;
    }

    try {
      print('📸 CameraService: Capturing photo...');

      // Capture image
      final XFile image = await _controller!.takePicture();
      
      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = customName ?? 'photo_$timestamp.jpg';
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory(path.join(directory.path, 'photos'));
      
      // Create photos directory if it doesn't exist
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final outputPath = path.join(photosDir.path, filename);
      
      if (compress) {
        // Compress and save image
        final compressedBytes = await ImageUtils.compressImage(
          File(image.path),
          quality: quality,
        );
        
        if (compressedBytes != null) {
          final outputFile = File(outputPath);
          await outputFile.writeAsBytes(compressedBytes);
          
          // Delete temporary file
          await File(image.path).delete();
          
          print('✅ CameraService: Photo captured and compressed: $outputPath');
          return outputFile;
        }
      }
      
      // Save without compression (fallback)
      final outputFile = await File(image.path).copy(outputPath);
      await File(image.path).delete();
      
      print('✅ CameraService: Photo captured: $outputPath');
      return outputFile;
    } catch (e) {
      print('❌ CameraService: Failed to capture photo: $e');
      return null;
    }
  }

  /// Capture multiple photos
  Future<List<File>> captureMultiplePhotos(int count) async {
    final photos = <File>[];
    
    for (int i = 0; i < count; i++) {
      final photo = await capturePhoto(customName: 'photo_${DateTime.now().millisecondsSinceEpoch}_${i + 1}.jpg');
      if (photo != null) {
        photos.add(photo);
        // Small delay between captures
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    print('✅ CameraService: Captured ${photos.length} photos');
    return photos;
  }

  /// Get storage usage for photos
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory(path.join(directory.path, 'photos'));
      
      if (!await photosDir.exists()) {
        return {'totalSize': 0, 'fileCount': 0, 'photos': []};
      }

      final files = await photosDir.list().toList();
      final photoFiles = files.whereType<File>().where((file) => 
          file.path.toLowerCase().endsWith('.jpg') || 
          file.path.toLowerCase().endsWith('.jpeg') ||
          file.path.toLowerCase().endsWith('.png')).toList();

      int totalSize = 0;
      final photoInfo = <Map<String, dynamic>>[];

      for (final file in photoFiles) {
        final stat = await file.stat();
        totalSize += stat.size;
        photoInfo.add({
          'path': file.path,
          'name': path.basename(file.path),
          'size': stat.size,
          'modified': stat.modified,
        });
      }

      return {
        'totalSize': totalSize,
        'fileCount': photoFiles.length,
        'photos': photoInfo,
      };
    } catch (e) {
      print('❌ CameraService: Failed to get storage info: $e');
      return {'totalSize': 0, 'fileCount': 0, 'photos': []};
    }
  }

  /// Clean up old photos (older than specified days)
  Future<int> cleanupOldPhotos({int olderThanDays = 30}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory(path.join(directory.path, 'photos'));
      
      if (!await photosDir.exists()) {
        return 0;
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      final files = await photosDir.list().toList();
      int deletedCount = 0;

      for (final file in files.whereType<File>()) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
          deletedCount++;
        }
      }

      print('✅ CameraService: Cleaned up $deletedCount old photos');
      return deletedCount;
    } catch (e) {
      print('❌ CameraService: Failed to cleanup old photos: $e');
      return 0;
    }
  }

  /// Get flash modes supported by current camera
  List<FlashMode> getSupportedFlashModes() {
    if (!isInitialized) return [];
    
    // Most cameras support these basic modes
    return [
      FlashMode.off,
      FlashMode.auto,
      FlashMode.always,
    ];
  }

  /// Check if current camera supports flash
  bool get hasFlash {
    if (currentCamera == null) return false;
    // Most back cameras have flash, front cameras typically don't
    return currentCamera!.lensDirection == CameraLensDirection.back;
  }

  /// Dispose camera service
  Future<void> dispose() async {
    print('🔄 CameraService: Disposing camera service...');
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    print('✅ CameraService: Camera service disposed');
  }

  /// Reset camera service (reinitialize)
  Future<bool> reset() async {
    print('🔄 CameraService: Resetting camera service...');
    await dispose();
    return await initialize();
  }
}