import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing receipt header logo storage and retrieval
class LogoService {
  static const String _logoPathKey = 'receipt_logo_path';
  static const String _logoFileName = 'receipt_logo.png';
  static const int _maxLogoWidth = 384; // Max width for thermal printer (58mm)
  static const int _maxLogoHeight = 200; // Reasonable height limit

  /// Save logo image to local storage
  Future<String?> saveLogo(Uint8List imageBytes) async {
    try {
      debugPrint('Starting saveLogo with ${imageBytes.length} bytes');
      
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final logoDir = Directory('${directory.path}/logos');
      debugPrint('Logo directory: ${logoDir.path}');
      
      // Create logos directory if it doesn't exist
      if (!await logoDir.exists()) {
        debugPrint('Creating logo directory...');
        await logoDir.create(recursive: true);
      }

      // Process and resize image
      debugPrint('Processing image...');
      final processedBytes = await _processImage(imageBytes);
      if (processedBytes == null) {
        debugPrint('Image processing failed');
        throw Exception('Failed to process image');
      }
      debugPrint('Image processed successfully, ${processedBytes.length} bytes');

      // Save processed image
      final logoFile = File('${logoDir.path}/$_logoFileName');
      debugPrint('Saving to file: ${logoFile.path}');
      await logoFile.writeAsBytes(processedBytes);

      // Verify file was saved
      final fileExists = await logoFile.exists();
      final fileSize = await logoFile.length();
      debugPrint('File saved: $fileExists, size: $fileSize bytes');

      // Store path in preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_logoPathKey, logoFile.path);
      debugPrint('Path stored in preferences: ${logoFile.path}');

      debugPrint('Logo saved successfully: ${logoFile.path}');
      return logoFile.path;
    } catch (e) {
      debugPrint('Error saving logo: $e');
      rethrow;
    }
  }

  /// Get current logo file path
  Future<String?> getLogoPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logoPath = prefs.getString(_logoPathKey);
      debugPrint('Stored logo path from preferences: $logoPath');
      
      // Verify file still exists
      if (logoPath != null) {
        final file = File(logoPath);
        final fileExists = await file.exists();
        debugPrint('Logo file exists: $fileExists at path: $logoPath');
        
        if (fileExists) {
          return logoPath;
        } else {
          debugPrint('Logo file no longer exists, cleaning up preferences');
          // Clean up invalid path
          await prefs.remove(_logoPathKey);
        }
      }
      
      debugPrint('No valid logo path found');
      return null;
    } catch (e) {
      debugPrint('Error getting logo path: $e');
      return null;
    }
  }

  /// Get logo as bytes for printing
  Future<Uint8List?> getLogoBytes() async {
    try {
      final logoPath = await getLogoPath();
      if (logoPath == null) return null;

      final file = File(logoPath);
      if (!await file.exists()) return null;

      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Error reading logo bytes: $e');
      return null;
    }
  }

  /// Check if logo exists
  Future<bool> hasLogo() async {
    final logoPath = await getLogoPath();
    final hasLogo = logoPath != null;
    debugPrint('hasLogo: $hasLogo (path: $logoPath)');
    return hasLogo;
  }

  /// Delete current logo
  Future<bool> deleteLogo() async {
    try {
      final logoPath = await getLogoPath();
      if (logoPath != null) {
        final file = File(logoPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Remove from preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logoPathKey);

      debugPrint('Logo deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting logo: $e');
      return false;
    }
  }

  /// Process image: resize, optimize for thermal printing
  Future<Uint8List?> _processImage(Uint8List originalBytes) async {
    try {
      debugPrint('Starting image processing...');
      
      // Decode image
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) {
        debugPrint('Failed to decode image');
        return null;
      }
      
      debugPrint('Original image size: ${originalImage.width}x${originalImage.height}');

      // Calculate new dimensions maintaining aspect ratio
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (newWidth > _maxLogoWidth) {
        final ratio = _maxLogoWidth / newWidth;
        newWidth = _maxLogoWidth;
        newHeight = (newHeight * ratio).round();
      }

      if (newHeight > _maxLogoHeight) {
        final ratio = _maxLogoHeight / newHeight;
        newHeight = _maxLogoHeight;
        newWidth = (newWidth * ratio).round();
      }

      debugPrint('New image size: ${newWidth}x$newHeight');

      // Resize image
      final resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.average,
      );
      
      debugPrint('Image resized successfully');

      // For now, skip color processing - just use resized image
      // TODO: Add back thermal printer optimization later
      debugPrint('Skipping color processing, using original colors');

      // Encode as PNG directly from resized image
      final processedBytes = img.encodePng(resizedImage);
      debugPrint('Image encoded, final size: ${processedBytes.length} bytes');
      
      return Uint8List.fromList(processedBytes);
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  /// Get image dimensions info
  Future<Map<String, int>?> getLogoDimensions() async {
    try {
      final logoBytes = await getLogoBytes();
      if (logoBytes == null) return null;

      final image = img.decodeImage(logoBytes);
      if (image == null) return null;

      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      debugPrint('Error getting logo dimensions: $e');
      return null;
    }
  }

  /// Get image file size in bytes
  Future<int?> getLogoFileSize() async {
    try {
      final logoPath = await getLogoPath();
      if (logoPath == null) return null;

      final file = File(logoPath);
      if (!await file.exists()) return null;

      return await file.length();
    } catch (e) {
      debugPrint('Error getting logo file size: $e');
      return null;
    }
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Validate image file
  Future<bool> isValidImage(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return false;
      
      // Check minimum dimensions
      if (image.width < 50 || image.height < 50) return false;
      
      // Check maximum file size (2MB)
      if (imageBytes.length > 2 * 1024 * 1024) return false;
      
      return true;
    } catch (e) {
      debugPrint('Error validating image: $e');
      return false;
    }
  }
}