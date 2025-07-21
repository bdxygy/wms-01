import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

/// Utility class for image processing and optimization
class ImageUtils {
  static const int _defaultQuality = 85;
  static const int _maxWidth = 1920;
  static const int _maxHeight = 1080;

  /// Compress image file and return bytes
  static Future<Uint8List?> compressImage(
    File imageFile, {
    int quality = _defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
     debugPrint('🖼️ ImageUtils: Compressing image ${path.basename(imageFile.path)}...');
      
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();
      
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
       debugPrint('❌ ImageUtils: Failed to decode image');
        return null;
      }

     debugPrint('🖼️ ImageUtils: Original size: ${image.width}x${image.height}');

      // Resize if necessary
      img.Image resizedImage = image;
      final targetWidth = maxWidth ?? _maxWidth;
      final targetHeight = maxHeight ?? _maxHeight;

      if (image.width > targetWidth || image.height > targetHeight) {
        // Calculate new dimensions maintaining aspect ratio
        double ratio = image.width / image.height;
        int newWidth = targetWidth;
        int newHeight = (newWidth / ratio).round();

        if (newHeight > targetHeight) {
          newHeight = targetHeight;
          newWidth = (newHeight * ratio).round();
        }

        resizedImage = img.copyResize(
          image,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );

       debugPrint('🖼️ ImageUtils: Resized to: ${resizedImage.width}x${resizedImage.height}');
      }

      // Compress and encode as JPEG
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      
      final originalSize = imageBytes.length;
      final compressedSize = compressedBytes.length;
      final compressionRatio = ((originalSize - compressedSize) / originalSize * 100).round();
      
     debugPrint('✅ ImageUtils: Compressed ${formatBytes(originalSize)} → ${formatBytes(compressedSize)} ($compressionRatio% reduction)');
      
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
     debugPrint('❌ ImageUtils: Failed to compress image: $e');
      return null;
    }
  }

  /// Compress image bytes directly
  static Future<Uint8List?> compressImageBytes(
    Uint8List imageBytes, {
    int quality = _defaultQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
       debugPrint('❌ ImageUtils: Failed to decode image bytes');
        return null;
      }

      // Resize if necessary
      img.Image resizedImage = image;
      final targetWidth = maxWidth ?? _maxWidth;
      final targetHeight = maxHeight ?? _maxHeight;

      if (image.width > targetWidth || image.height > targetHeight) {
        double ratio = image.width / image.height;
        int newWidth = targetWidth;
        int newHeight = (newWidth / ratio).round();

        if (newHeight > targetHeight) {
          newHeight = targetHeight;
          newWidth = (newHeight * ratio).round();
        }

        resizedImage = img.copyResize(
          image,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // Compress and encode as JPEG
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
     debugPrint('❌ ImageUtils: Failed to compress image bytes: $e');
      return null;
    }
  }

  /// Create thumbnail from image file
  static Future<Uint8List?> createThumbnail(
    File imageFile, {
    int size = 200,
    int quality = 70,
  }) async {
    try {
     debugPrint('🖼️ ImageUtils: Creating thumbnail for ${path.basename(imageFile.path)}...');
      
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
       debugPrint('❌ ImageUtils: Failed to decode image for thumbnail');
        return null;
      }

      // Create square thumbnail
      final thumbnail = img.copyResizeCropSquare(image, size: size);
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: quality);
      
     debugPrint('✅ ImageUtils: Thumbnail created: ${size}x$size (${formatBytes(thumbnailBytes.length)})');
      return Uint8List.fromList(thumbnailBytes);
    } catch (e) {
     debugPrint('❌ ImageUtils: Failed to create thumbnail: $e');
      return null;
    }
  }

  /// Get image information (dimensions, size, format)
  static Future<Map<String, dynamic>?> getImageInfo(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        return null;
      }

      final stat = await imageFile.stat();
      
      return {
        'width': image.width,
        'height': image.height,
        'size': stat.size,
        'format': _getImageFormat(imageFile.path),
        'aspectRatio': image.width / image.height,
        'megapixels': (image.width * image.height / 1000000).toStringAsFixed(1),
      };
    } catch (e) {
     debugPrint('❌ ImageUtils: Failed to get image info: $e');
      return null;
    }
  }

  /// Convert image to different format
  static Future<Uint8List?> convertImageFormat(
    File imageFile,
    ImageFormat targetFormat, {
    int quality = _defaultQuality,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        return null;
      }

      switch (targetFormat) {
        case ImageFormat.jpeg:
          return Uint8List.fromList(img.encodeJpg(image, quality: quality));
        case ImageFormat.png:
          return Uint8List.fromList(img.encodePng(image));
        case ImageFormat.webp:
          return Uint8List.fromList(img.encodeJpg(image, quality: quality));
      }
    } catch (e) {
     debugPrint('❌ ImageUtils: Failed to convert image format: $e');
      return null;
    }
  }

  /// Apply image filters/enhancements
  static Future<Uint8List?> enhanceImage(
    File imageFile, {
    double brightness = 0.0, // -100 to 100
    double contrast = 0.0,   // -100 to 100
    double saturation = 0.0, // -100 to 100
    bool autoLevel = false,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        return null;
      }

      img.Image enhancedImage = image;

      // Apply auto-level if requested
      if (autoLevel) {
        enhancedImage = img.normalize(enhancedImage, min: 0, max: 255);
      }

      // Apply brightness
      if (brightness != 0.0) {
        enhancedImage = img.adjustColor(enhancedImage, brightness: brightness / 100.0);
      }

      // Apply contrast
      if (contrast != 0.0) {
        enhancedImage = img.adjustColor(enhancedImage, contrast: contrast / 100.0);
      }

      // Apply saturation
      if (saturation != 0.0) {
        enhancedImage = img.adjustColor(
          enhancedImage,
          saturation: saturation / 100.0,
        );
      }

      return Uint8List.fromList(img.encodeJpg(enhancedImage, quality: _defaultQuality));
    } catch (e) {
     debugPrint('❌ ImageUtils: Failed to enhance image: $e');
      return null;
    }
  }

  /// Rotate image by degrees (90, 180, 270)
  static Future<Uint8List?> rotateImage(
    File imageFile,
    int degrees,
  ) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        return null;
      }

      img.Image rotatedImage;
      switch (degrees % 360) {
        case 90:
          rotatedImage = img.copyRotate(image, angle: 90);
          break;
        case 180:
          rotatedImage = img.copyRotate(image, angle: 180);
          break;
        case 270:
          rotatedImage = img.copyRotate(image, angle: 270);
          break;
        default:
          rotatedImage = image;
      }

      return Uint8List.fromList(img.encodeJpg(rotatedImage, quality: _defaultQuality));
    } catch (e) {
     debugPrint('❌ ImageUtils: Failed to rotate image: $e');
      return null;
    }
  }

  /// Format bytes to human readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get image format from file extension
  static String _getImageFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'JPEG';
      case '.png':
        return 'PNG';
      case '.webp':
        return 'WebP';
      case '.gif':
        return 'GIF';
      case '.bmp':
        return 'BMP';
      default:
        return 'Unknown';
    }
  }

  /// Validate if file is a valid image
  static bool isValidImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp'].contains(extension);
  }

  /// Calculate optimal compression quality based on file size
  static int calculateOptimalQuality(int fileSizeBytes) {
    // Larger files need more compression
    if (fileSizeBytes > 5 * 1024 * 1024) return 70; // 5MB+
    if (fileSizeBytes > 2 * 1024 * 1024) return 80; // 2-5MB
    if (fileSizeBytes > 1 * 1024 * 1024) return 85; // 1-2MB
    return 90; // <1MB
  }
}

/// Supported image formats for conversion
enum ImageFormat {
  jpeg,
  png,
  webp,
}