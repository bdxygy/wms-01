import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../generated/app_localizations.dart';

/// Service for image selection from camera or gallery
class ImagePickerService {
  static final ImagePickerService _instance = ImagePickerService._internal();
  factory ImagePickerService() => _instance;
  ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Show image source selection dialog
  Future<Uint8List?> pickImage(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    return showModalBottomSheet<Uint8List>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                l10n.logo_select_image_source,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                l10n.logo_select_image_subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Camera option
              _buildImageSourceOption(
                context: context,
                icon: Icons.camera_alt_outlined,
                title: l10n.logo_camera_option,
                subtitle: l10n.logo_camera_subtitle,
                onTap: () async {
                  final bytes = await _pickFromCamera(context);
                  if (context.mounted) {
                    Navigator.of(context).pop(bytes);
                  }
                },
              ),
              
              const SizedBox(height: 12),
              
              // Gallery option
              _buildImageSourceOption(
                context: context,
                icon: Icons.photo_library_outlined,
                title: l10n.logo_gallery_option,
                subtitle: l10n.logo_gallery_subtitle,
                onTap: () async {
                  final bytes = await _pickFromGallery(context);
                  if (context.mounted) {
                    Navigator.of(context).pop(bytes);
                  }
                },
              ),
              
              const SizedBox(height: 12),
              
              // Cancel button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.common_button_cancel),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Pick image from camera
  Future<Uint8List?> _pickFromCamera(BuildContext context) async {
    try {
      debugPrint('Checking camera permission...');
      // Check camera permission
      if (!await _checkCameraPermission(context)) {
        debugPrint('Camera permission denied');
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          _showErrorSnackBar(context, l10n.camera_permission_required);
        }
        return null;
      }

      debugPrint('Camera permission granted, opening camera...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        debugPrint('Image captured successfully: ${image.path}');
        final bytes = await image.readAsBytes();
        debugPrint('Image bytes loaded: ${bytes.length} bytes');
        return bytes;
      }
      
      debugPrint('No image captured (user cancelled or error)');
      return null;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to capture image: $e');
      }
      return null;
    }
  }

  /// Pick image from gallery
  Future<Uint8List?> _pickFromGallery(BuildContext context) async {
    try {
      debugPrint('Checking photo gallery permission...');
      // Check photo permission
      if (!await _checkPhotoPermission(context)) {
        debugPrint('Gallery permission denied');
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          _showErrorSnackBar(context, l10n.gallery_permission_required);
        }
        return null;
      }

      debugPrint('Gallery permission granted, opening gallery...');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        debugPrint('Image selected successfully: ${image.path}');
        final bytes = await image.readAsBytes();
        debugPrint('Image bytes loaded: ${bytes.length} bytes');
        return bytes;
      }
      
      debugPrint('No image selected (user cancelled)');
      return null;
    } catch (e) {
      debugPrint('Error selecting image: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to select image: $e');
      }
      return null;
    }
  }

  /// Check camera permission
  Future<bool> _checkCameraPermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    final permission = await Permission.camera.status;
    debugPrint('Camera permission status: $permission');
    
    if (permission.isGranted) {
      debugPrint('Camera permission already granted');
      return true;
    }
    
    if (permission.isDenied) {
      debugPrint('Requesting camera permission...');
      final result = await Permission.camera.request();
      debugPrint('Camera permission request result: $result');
      if (result.isGranted) return true;
    }
    
    if (permission.isPermanentlyDenied || permission.isDenied) {
      debugPrint('Camera permission permanently denied or denied');
      if (context.mounted) {
        _showPermissionDialog(
          context,
          title: l10n.logo_camera_permission_title,
          message: l10n.logo_camera_permission_message,
        );
      }
      return false;
    }
    
    return false;
  }

  /// Check photo permission
  Future<bool> _checkPhotoPermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // For Android 13+ (API 33+), use READ_MEDIA_IMAGES permission
    // For older versions, use photos permission
    final permission = await Permission.photos.status;
    
    if (permission.isGranted) return true;
    
    if (permission.isDenied) {
      final result = await Permission.photos.request();
      if (result.isGranted) return true;
    }
    
    // Also try storage permission as fallback for older devices
    if (permission.isDenied || permission.isPermanentlyDenied) {
      final storagePermission = await Permission.storage.status;
      if (storagePermission.isGranted) return true;
      
      if (storagePermission.isDenied) {
        final storageResult = await Permission.storage.request();
        if (storageResult.isGranted) return true;
      }
    }
    
    if (permission.isPermanentlyDenied || permission.isDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          title: l10n.logo_gallery_permission_title,
          message: l10n.logo_gallery_permission_message,
        );
      }
      return false;
    }
    
    return false;
  }

  /// Show permission dialog
  void _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_button_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(l10n.common_button_settings),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}