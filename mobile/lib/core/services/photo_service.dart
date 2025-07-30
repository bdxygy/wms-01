import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/photo.dart';
import 'image_picker_service.dart';

/// Comprehensive service for photo management
/// 
/// Handles all photo operations including upload, retrieval, update, and deletion
/// Supports three photo types: product, photoProof, transferProof
/// 
/// Features:
/// - Multipart file uploads with progress tracking
/// - Cloudinary integration for optimized image delivery
/// - Role-based access control
/// - Store-scoped operations
/// - Integration with ImagePickerService for image selection
/// - Comprehensive error handling
/// 
/// Example Usage:
/// ```dart
/// final photoService = PhotoService();
/// 
/// // Upload product photo
/// final productPhoto = await photoService.uploadProductPhoto(
///   productId: 'product-uuid',
///   imageBytes: imageBytes,
///   onProgress: (progress) => print('Upload progress: $progress%'),
/// );
/// 
/// // Upload transaction photo proof
/// final photoProof = await photoService.uploadTransactionPhotoProof(
///   transactionId: 'transaction-uuid',
///   imageBytes: imageBytes,
/// );
/// 
/// // Get all photos for a transaction
/// final transactionPhotos = await photoService.getPhotosByTransactionId(
///   'transaction-uuid',
///   type: PhotoType.photoProof,
/// );
/// 
/// // Update product photo
/// final updatedPhoto = await photoService.updateProductPhoto(
///   productId: 'product-uuid',
///   imageBytes: newImageBytes,
/// );
/// 
/// // Delete photo
/// await photoService.deletePhoto('photo-uuid');
/// ```
class PhotoService {
  final ApiClient _apiClient = ApiClient.instance;
  final ImagePickerService _imagePickerService = ImagePickerService();

  // === Upload Methods ===

  /// Upload photo with multipart form data
  /// 
  /// Supports all photo types and provides upload progress tracking
  Future<Photo> uploadPhoto(
    UploadPhotoRequest request,
    Uint8List imageBytes, {
    String? fileName,
    ProgressCallback? onProgress,
  }) async {
    try {
      // Validate request
      final validationErrors = request.validate();
      if (validationErrors.isNotEmpty) {
        throw ArgumentError('Invalid upload request: ${validationErrors.join(', ')}');
      }

      // Create form data
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'type': request.type.apiValue,
        if (request.transactionId != null) 'transactionId': request.transactionId,
        if (request.productId != null) 'productId': request.productId,
      });

      debugPrint('Uploading photo: ${request.type.apiValue}, '
          'transactionId: ${request.transactionId}, '
          'productId: ${request.productId}');

      final response = await _apiClient.upload(
        ApiEndpoints.photosUpload,
        formData,
        onSendProgress: onProgress,
      );

      final apiResponse = ApiResponse<Photo>.fromJson(
        response.data,
        (json) => Photo.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to upload photo');
      }

      debugPrint('Photo uploaded successfully: ${apiResponse.data!.id}');
      return apiResponse.data!;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      rethrow;
    }
  }

  /// Upload product photo
  Future<Photo> uploadProductPhoto(
    String productId,
    Uint8List imageBytes, {
    String? fileName,
    ProgressCallback? onProgress,
  }) async {
    final request = UploadPhotoRequest.forProduct(productId);
    return uploadPhoto(request, imageBytes, fileName: fileName, onProgress: onProgress);
  }

  /// Upload transaction photo proof
  Future<Photo> uploadTransactionPhotoProof(
    String transactionId,
    Uint8List imageBytes, {
    String? fileName,
    ProgressCallback? onProgress,
  }) async {
    final request = UploadPhotoRequest.forPhotoProof(transactionId);
    return uploadPhoto(request, imageBytes, fileName: fileName, onProgress: onProgress);
  }

  /// Upload transaction transfer proof
  Future<Photo> uploadTransactionTransferProof(
    String transactionId,
    Uint8List imageBytes, {
    String? fileName,
    ProgressCallback? onProgress,
  }) async {
    final request = UploadPhotoRequest.forTransferProof(transactionId);
    return uploadPhoto(request, imageBytes, fileName: fileName, onProgress: onProgress);
  }

  // === Retrieval Methods ===

  /// Get photos by transaction ID with optional type filtering
  Future<List<Photo>> getPhotosByTransactionId(
    String transactionId, {
    PhotoType? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) {
        queryParams['type'] = type.apiValue;
      }

      debugPrint('Getting photos for transaction: $transactionId, type: ${type?.apiValue}');

      final response = await _apiClient.get(
        ApiEndpoints.photosByTransactionId(transactionId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final apiResponse = ApiResponse<List<Photo>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((item) => Photo.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to get transaction photos');
      }

      debugPrint('Retrieved ${apiResponse.data!.length} photos for transaction: $transactionId');
      return apiResponse.data!;
    } catch (e) {
      debugPrint('Error getting transaction photos: $e');
      rethrow;
    }
  }

  /// Get photos by product ID
  Future<List<Photo>> getPhotosByProductId(String productId) async {
    try {
      debugPrint('Getting photos for product: $productId');

      final response = await _apiClient.get(
        ApiEndpoints.photosByProductId(productId),
      );

      final apiResponse = ApiResponse<List<Photo>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((item) => Photo.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to get product photos');
      }

      debugPrint('Retrieved ${apiResponse.data!.length} photos for product: $productId');
      return apiResponse.data!;
    } catch (e) {
      debugPrint('Error getting product photos: $e');
      rethrow;
    }
  }

  /// Get single photo proof for transaction
  Future<Photo?> getTransactionPhotoProof(String transactionId) async {
    final photos = await getPhotosByTransactionId(
      transactionId,
      type: PhotoType.photoProof,
    );
    return photos.isNotEmpty ? photos.first : null;
  }

  /// Get single transfer proof for transaction
  Future<Photo?> getTransactionTransferProof(String transactionId) async {
    final photos = await getPhotosByTransactionId(
      transactionId,
      type: PhotoType.transferProof,
    );
    return photos.isNotEmpty ? photos.first : null;
  }

  /// Get single product photo
  Future<Photo?> getProductPhoto(String productId) async {
    final photos = await getPhotosByProductId(productId);
    return photos.isNotEmpty ? photos.first : null;
  }

  // === Update Methods ===

  /// Update photo by transaction ID and type (replace existing or create new)
  Future<Photo> updatePhotoByTransaction(
    String transactionId,
    PhotoType type,
    Uint8List imageBytes, {
    String? fileName,
    ProgressCallback? onProgress,
  }) async {
    try {
      if (!type.isTransactionPhoto) {
        throw ArgumentError('Invalid photo type for transaction: ${type.apiValue}');
      }

      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      debugPrint('Updating transaction photo: $transactionId, type: ${type.apiValue}');

      final response = await _apiClient.putUpload(
        ApiEndpoints.photosUpdateByTransaction(transactionId),
        formData,
        queryParameters: {'type': type.apiValue},
        onSendProgress: onProgress,
      );

      final apiResponse = ApiResponse<Photo>.fromJson(
        response.data,
        (json) => Photo.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to update transaction photo');
      }

      debugPrint('Transaction photo updated successfully: ${apiResponse.data!.id}');
      return apiResponse.data!;
    } catch (e) {
      debugPrint('Error updating transaction photo: $e');
      rethrow;
    }
  }

  /// Update product photo (replace existing or create new)
  Future<Photo> updateProductPhoto(
    String productId,
    Uint8List imageBytes, {
    String? fileName,
    ProgressCallback? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      debugPrint('Updating product photo: $productId');

      final response = await _apiClient.putUpload(
        ApiEndpoints.photosUpdateByProduct(productId),
        formData,
        onSendProgress: onProgress,
      );

      final apiResponse = ApiResponse<Photo>.fromJson(
        response.data,
        (json) => Photo.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw Exception(apiResponse.error?.message ?? 'Failed to update product photo');
      }

      debugPrint('Product photo updated successfully: ${apiResponse.data!.id}');
      return apiResponse.data!;
    } catch (e) {
      debugPrint('Error updating product photo: $e');
      rethrow;
    }
  }

  /// Update transaction photo proof
  Future<Photo> updateTransactionPhotoProof(
    String transactionId,
    Uint8List imageBytes, {
    String? fileName,
    ProgressCallback? onProgress,
  }) async {
    return updatePhotoByTransaction(
      transactionId,
      PhotoType.photoProof,
      imageBytes,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Update transaction transfer proof
  Future<Photo> updateTransactionTransferProof(
    String transactionId,
    Uint8List imageBytes, {
    String? fileName,
    ProgressCallback? onProgress,
  }) async {
    return updatePhotoByTransaction(
      transactionId,
      PhotoType.transferProof,
      imageBytes,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  // === Delete Methods ===

  /// Delete photo by ID
  Future<void> deletePhoto(String photoId) async {
    try {
      debugPrint('Deleting photo: $photoId');

      final response = await _apiClient.delete(ApiEndpoints.photosDelete(photoId));

      final apiResponse = ApiResponse<DeletePhotoResponse>.fromJson(
        response.data,
        (json) => DeletePhotoResponse.fromJson(json as Map<String, dynamic>),
      );

      if (!apiResponse.success) {
        throw Exception(apiResponse.error?.message ?? 'Failed to delete photo');
      }

      debugPrint('Photo deleted successfully: $photoId');
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      rethrow;
    }
  }

  // === Helper Methods with ImagePickerService Integration ===

  /// Upload product photo with image picker integration
  Future<Photo?> uploadProductPhotoWithPicker(
    String productId, {
    required BuildContext context,
    ProgressCallback? onProgress,
  }) async {
    try {
      final imageBytes = await _imagePickerService.pickImage(context);
      if (imageBytes == null) {
        debugPrint('No image selected for product photo upload');
        return null;
      }

      return await uploadProductPhoto(
        productId,
        imageBytes,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Error uploading product photo with picker: $e');
      rethrow;
    }
  }

  /// Upload transaction photo proof with image picker integration
  Future<Photo?> uploadTransactionPhotoProofWithPicker(
    String transactionId, {
    required BuildContext context,
    ProgressCallback? onProgress,
  }) async {
    try {
      final imageBytes = await _imagePickerService.pickImage(context);
      if (imageBytes == null) {
        debugPrint('No image selected for photo proof upload');
        return null;
      }

      return await uploadTransactionPhotoProof(
        transactionId,
        imageBytes,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Error uploading photo proof with picker: $e');
      rethrow;
    }
  }

  /// Upload transaction transfer proof with image picker integration
  Future<Photo?> uploadTransactionTransferProofWithPicker(
    String transactionId, {
    required BuildContext context,
    ProgressCallback? onProgress,
  }) async {
    try {
      final imageBytes = await _imagePickerService.pickImage(context);
      if (imageBytes == null) {
        debugPrint('No image selected for transfer proof upload');
        return null;
      }

      return await uploadTransactionTransferProof(
        transactionId,
        imageBytes,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Error uploading transfer proof with picker: $e');
      rethrow;
    }
  }

  /// Update product photo with image picker integration
  Future<Photo?> updateProductPhotoWithPicker(
    String productId, {
    required BuildContext context,
    ProgressCallback? onProgress,
  }) async {
    try {
      final imageBytes = await _imagePickerService.pickImage(context);
      if (imageBytes == null) {
        debugPrint('No image selected for product photo update');
        return null;
      }

      return await updateProductPhoto(
        productId,
        imageBytes,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Error updating product photo with picker: $e');
      rethrow;
    }
  }

  /// Update transaction photo proof with image picker integration
  Future<Photo?> updateTransactionPhotoProofWithPicker(
    String transactionId, {
    required BuildContext context,
    ProgressCallback? onProgress,
  }) async {
    try {
      final imageBytes = await _imagePickerService.pickImage(context);
      if (imageBytes == null) {
        debugPrint('No image selected for photo proof update');
        return null;
      }

      return await updateTransactionPhotoProof(
        transactionId,
        imageBytes,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Error updating photo proof with picker: $e');
      rethrow;
    }
  }

  /// Update transaction transfer proof with image picker integration
  Future<Photo?> updateTransactionTransferProofWithPicker(
    String transactionId, {
    required BuildContext context,
    ProgressCallback? onProgress,
  }) async {
    try {
      final imageBytes = await _imagePickerService.pickImage(context);
      if (imageBytes == null) {
        debugPrint('No image selected for transfer proof update');
        return null;
      }

      return await updateTransactionTransferProof(
        transactionId,
        imageBytes,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Error updating transfer proof with picker: $e');
      rethrow;
    }
  }

  // === Utility Methods ===

  /// Check if photo exists for product
  Future<bool> hasProductPhoto(String productId) async {
    try {
      final photos = await getPhotosByProductId(productId);
      return photos.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking product photo existence: $e');
      return false;
    }
  }

  /// Check if transaction has photo proof
  Future<bool> hasTransactionPhotoProof(String transactionId) async {
    try {
      final photo = await getTransactionPhotoProof(transactionId);
      return photo != null;
    } catch (e) {
      debugPrint('Error checking transaction photo proof existence: $e');
      return false;
    }
  }

  /// Check if transaction has transfer proof
  Future<bool> hasTransactionTransferProof(String transactionId) async {
    try {
      final photo = await getTransactionTransferProof(transactionId);
      return photo != null;
    } catch (e) {
      debugPrint('Error checking transaction transfer proof existence: $e');
      return false;
    }
  }

  /// Get all photos for transaction (both photo proof and transfer proof)
  Future<Map<PhotoType, Photo?>> getAllTransactionPhotos(String transactionId) async {
    try {
      final photos = await getPhotosByTransactionId(transactionId);
      
      final result = <PhotoType, Photo?>{
        PhotoType.photoProof: null,
        PhotoType.transferProof: null,
      };

      for (final photo in photos) {
        if (photo.type == PhotoType.photoProof) {
          result[PhotoType.photoProof] = photo;
        } else if (photo.type == PhotoType.transferProof) {
          result[PhotoType.transferProof] = photo;
        }
      }

      return result;
    } catch (e) {
      debugPrint('Error getting all transaction photos: $e');
      rethrow;
    }
  }

  /// Calculate upload progress percentage from bytes
  static double calculateUploadProgress(int sent, int total) {
    if (total <= 0) return 0;
    return (sent / total * 100).clamp(0, 100);
  }

  /// Create progress callback that reports percentages
  static ProgressCallback createProgressCallback(
    void Function(double percentage) onProgress,
  ) {
    return (int sent, int total) {
      final percentage = calculateUploadProgress(sent, total);
      onProgress(percentage);
    };
  }
}