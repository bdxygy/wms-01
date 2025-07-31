import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/models/photo.dart';
import '../../../core/services/photo_service.dart';
import '../../../core/services/image_picker_service.dart';

/// Widget for uploading and managing transaction photos
/// 
/// Supports both photoProof and transferProof types with:
/// - Image selection from camera/gallery
/// - Photo preview and management
/// - Upload progress tracking
/// - Error handling and user feedback
/// - Consistent UI with transaction form
class TransactionPhotoUpload extends StatefulWidget {
  final PhotoType type;
  final String? initialPhotoUrl;
  final String? existingPhotoId;
  final String? transactionId;
  final Function(String? photoUrl, String? photoId, [Uint8List? imageBytes]) onPhotoChanged;
  final String title;
  final String? subtitle;
  final bool isRequired;

  const TransactionPhotoUpload({
    super.key,
    required this.type,
    this.initialPhotoUrl,
    this.existingPhotoId,
    this.transactionId,
    required this.onPhotoChanged,
    required this.title,
    this.subtitle,
    this.isRequired = false,
  });

  @override
  State<TransactionPhotoUpload> createState() => _TransactionPhotoUploadState();
}

class _TransactionPhotoUploadState extends State<TransactionPhotoUpload> {
  final PhotoService _photoService = PhotoService();
  final ImagePickerService _imagePickerService = ImagePickerService();

  String? _currentPhotoUrl;
  String? _currentPhotoId;
  Uint8List? _localImageBytes;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentPhotoUrl = widget.initialPhotoUrl;
    _currentPhotoId = widget.existingPhotoId;
  }

  /// Handle photo selection (and upload if transaction exists)
  Future<void> _selectAndUploadPhoto() async {
    if (!mounted) return;

    try {
      setState(() {
        _errorMessage = null;
      });

      // Select image using ImagePickerService
      final imageBytes = await _imagePickerService.pickImage(context);
      if (imageBytes == null) {
        debugPrint('No image selected');
        return;
      }

      setState(() {
        _localImageBytes = imageBytes;
      });

      // If transaction exists, upload immediately
      if (widget.transactionId != null) {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });

        Photo uploadedPhoto;
        if (widget.type == PhotoType.photoProof) {
          uploadedPhoto = await _photoService.updateTransactionPhotoProof(
            widget.transactionId!,
            imageBytes,
            onProgress: _onUploadProgress,
          );
        } else if (widget.type == PhotoType.transferProof) {
          uploadedPhoto = await _photoService.updateTransactionTransferProof(
            widget.transactionId!,
            imageBytes,
            onProgress: _onUploadProgress,
          );
        } else {
          throw Exception('Invalid photo type for transaction: ${widget.type}');
        }

        setState(() {
          _currentPhotoUrl = uploadedPhoto.secureUrl;
          _currentPhotoId = uploadedPhoto.id;
          _isUploading = false;
          _uploadProgress = 100.0;
        });

        widget.onPhotoChanged(_currentPhotoUrl, _currentPhotoId);
        _showSuccessMessage('Photo uploaded successfully');
      } else {
        // Transaction doesn't exist yet, store locally for later upload
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        widget.onPhotoChanged('local_image_$tempId', tempId, imageBytes);
        // Don't show snackbar for photo selection, only when actually uploaded
      }

    } catch (e) {
      debugPrint('Error with photo: $e');
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _errorMessage = 'Failed to process photo: $e';
        _localImageBytes = null;
      });
      _showErrorMessage('Failed to process photo: $e');
    }
  }

  /// Upload stored photo using transaction ID
  Future<bool> uploadStoredPhoto(String transactionId) async {
    if (_localImageBytes == null) return false;
    
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _errorMessage = null;
      });

      Photo uploadedPhoto;
      if (widget.type == PhotoType.photoProof) {
        uploadedPhoto = await _photoService.updateTransactionPhotoProof(
          transactionId,
          _localImageBytes!,
          onProgress: _onUploadProgress,
        );
      } else if (widget.type == PhotoType.transferProof) {
        uploadedPhoto = await _photoService.updateTransactionTransferProof(
          transactionId,
          _localImageBytes!,
          onProgress: _onUploadProgress,
        );
      } else {
        throw Exception('Invalid photo type for transaction: ${widget.type}');
      }

      setState(() {
        _currentPhotoUrl = uploadedPhoto.secureUrl;
        _currentPhotoId = uploadedPhoto.id;
        _isUploading = false;
        _uploadProgress = 100.0;
      });

      // Update parent with actual photo data
      widget.onPhotoChanged(_currentPhotoUrl, _currentPhotoId);
      
      return true;
    } catch (e) {
      debugPrint('Error uploading stored photo: $e');
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _errorMessage = 'Failed to upload photo: $e';
      });
      return false;
    }
  }

  /// Check if has locally stored photo ready for upload
  bool get hasStoredPhoto => _localImageBytes != null && (_currentPhotoId?.startsWith('temp_') ?? false);

  /// Handle photo removal
  Future<void> _removePhoto() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      // If there's an existing photo on the server, delete it
      if (_currentPhotoId != null && !_currentPhotoId!.startsWith('temp_')) {
        await _photoService.deletePhoto(_currentPhotoId!);
      }

      setState(() {
        _currentPhotoUrl = null;
        _currentPhotoId = null;
        _localImageBytes = null;
        _uploadProgress = 0.0;
      });

      widget.onPhotoChanged(null, null);
      _showSuccessMessage('Photo removed');

    } catch (e) {
      debugPrint('Error removing photo: $e');
      _showErrorMessage('Failed to remove photo: $e');
    }
  }

  /// Upload progress callback
  void _onUploadProgress(int sent, int total) {
    if (mounted) {
      setState(() {
        _uploadProgress = PhotoService.calculateUploadProgress(sent, total);
      });
    }
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Show error message
  void _showErrorMessage(String message) {
    if (!mounted) return;
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

  /// Build photo preview
  Widget _buildPhotoPreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _localImageBytes != null
            ? Image.memory(
                _localImageBytes!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
              )
            : _currentPhotoUrl != null
                ? Image.network(
                    _currentPhotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                : _buildErrorPlaceholder(),
      ),
    );
  }

  /// Build error placeholder
  Widget _buildErrorPlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          style: BorderStyle.solid,
        ),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.type == PhotoType.photoProof
                ? Icons.photo_camera_outlined
                : Icons.file_upload_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No photo selected',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          if (widget.subtitle != null)
            Text(
              widget.subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    final hasPhoto = _currentPhotoUrl != null || _localImageBytes != null;

    if (hasPhoto) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isUploading ? null : _selectAndUploadPhoto,
              icon: Icon(
                Icons.photo_camera,
                size: 20,
              ),
              label: Text('Replace Photo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: _isUploading ? null : _removePhoto,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            child: const Icon(Icons.delete_outline, size: 20),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isUploading ? null : _selectAndUploadPhoto,
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  widget.type == PhotoType.photoProof
                      ? Icons.add_a_photo
                      : Icons.upload_file,
                  size: 20,
                ),
          label: Text(_isUploading ? 'Uploading...' : 'Add ${widget.title}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      );
    }
  }

  /// Build upload progress indicator
  Widget _buildUploadProgress() {
    return Column(
      children: [
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: _uploadProgress / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Uploading photo...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${_uploadProgress.toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build section label
  Widget _buildSectionLabel() {
    return Row(
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        if (widget.isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _currentPhotoUrl != null || _localImageBytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(),
        const SizedBox(height: 8),
        
        // Photo preview or empty state
        hasPhoto ? _buildPhotoPreview() : _buildEmptyState(),
        
        const SizedBox(height: 16),
        
        // Action buttons
        _buildActionButtons(),
        
        // Upload progress
        if (_isUploading) _buildUploadProgress(),
        
        // Error message
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}