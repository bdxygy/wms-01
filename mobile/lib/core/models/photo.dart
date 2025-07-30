import 'package:json_annotation/json_annotation.dart';

part 'photo.g.dart';

/// Photo types supported by the system
enum PhotoType {
  @JsonValue('product')
  product,
  @JsonValue('photoProof')
  photoProof,
  @JsonValue('transferProof')
  transferProof,
}

/// Extension for PhotoType enum utilities
extension PhotoTypeExtension on PhotoType {
  /// Get display name for photo type
  String get displayName {
    switch (this) {
      case PhotoType.product:
        return 'Product Photo';
      case PhotoType.photoProof:
        return 'Photo Proof';
      case PhotoType.transferProof:
        return 'Transfer Proof';
    }
  }

  /// Get API string value
  String get apiValue {
    switch (this) {
      case PhotoType.product:
        return 'product';
      case PhotoType.photoProof:
        return 'photoProof';
      case PhotoType.transferProof:
        return 'transferProof';
    }
  }

  /// Convert string to PhotoType
  static PhotoType fromString(String type) {
    switch (type) {
      case 'product':
        return PhotoType.product;
      case 'photoProof':
        return PhotoType.photoProof;
      case 'transferProof':
        return PhotoType.transferProof;
      default:
        throw ArgumentError('Invalid photo type: $type');
    }
  }

  /// Check if photo type is for transactions
  bool get isTransactionPhoto {
    return this == PhotoType.photoProof || this == PhotoType.transferProof;
  }

  /// Check if photo type is for products
  bool get isProductPhoto {
    return this == PhotoType.product;
  }
}

/// Photo model matching the API schema
@JsonSerializable()
class Photo {
  final String id;
  final String publicId;
  final String secureUrl;
  final PhotoType type;
  final String? transactionId;
  final String? productId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Photo({
    required this.id,
    required this.publicId,
    required this.secureUrl,
    required this.type,
    this.transactionId,
    this.productId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
  Map<String, dynamic> toJson() => _$PhotoToJson(this);

  /// Check if photo is soft deleted
  bool get isDeleted => deletedAt != null;

  /// Check if photo belongs to a transaction
  bool get belongsToTransaction => transactionId != null;

  /// Check if photo belongs to a product
  bool get belongsToProduct => productId != null;

  /// Get photo URL with optional transformations
  String getUrl({
    int? width,
    int? height,
    String? quality,
  }) {
    if (width == null && height == null && quality == null) {
      return secureUrl;
    }

    // Build Cloudinary transformation URL
    final baseUrl = secureUrl.split('/upload/')[0];
    final imagePath = secureUrl.split('/upload/')[1];
    
    final transformations = <String>[];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (quality != null) transformations.add('q_$quality');

    return '$baseUrl/upload/${transformations.join(',')}/v1/$imagePath';
  }

  /// Get thumbnail URL (200x200)
  String get thumbnailUrl => getUrl(width: 200, height: 200, quality: 'auto');

  /// Get medium size URL (500x500)
  String get mediumUrl => getUrl(width: 500, height: 500, quality: 'auto');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Photo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Photo{id: $id, type: $type, publicId: $publicId}';
  }
}

/// Request model for uploading photos
@JsonSerializable()
class UploadPhotoRequest {
  final PhotoType type;
  final String? transactionId;
  final String? productId;

  UploadPhotoRequest({
    required this.type,
    this.transactionId,
    this.productId,
  });

  factory UploadPhotoRequest.fromJson(Map<String, dynamic> json) =>
      _$UploadPhotoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UploadPhotoRequestToJson(this);

  /// Create request for product photo
  factory UploadPhotoRequest.forProduct(String productId) {
    return UploadPhotoRequest(
      type: PhotoType.product,
      productId: productId,
    );
  }

  /// Create request for transaction photo proof
  factory UploadPhotoRequest.forPhotoProof(String transactionId) {
    return UploadPhotoRequest(
      type: PhotoType.photoProof,
      transactionId: transactionId,
    );
  }

  /// Create request for transaction transfer proof
  factory UploadPhotoRequest.forTransferProof(String transactionId) {
    return UploadPhotoRequest(
      type: PhotoType.transferProof,
      transactionId: transactionId,
    );
  }

  /// Validate the request
  List<String> validate() {
    final errors = <String>[];

    if (type.isProductPhoto && productId == null) {
      errors.add('Product ID is required for product photos');
    }

    if (type.isTransactionPhoto && transactionId == null) {
      errors.add('Transaction ID is required for transaction photos');
    }

    if (productId != null && transactionId != null) {
      errors.add('Cannot specify both product ID and transaction ID');
    }

    if (productId == null && transactionId == null) {
      errors.add('Either product ID or transaction ID must be specified');
    }

    return errors;
  }

  /// Check if request is valid
  bool get isValid => validate().isEmpty;
}

/// Response model for photo deletion
@JsonSerializable()
class DeletePhotoResponse {
  final String message;

  DeletePhotoResponse({
    required this.message,
  });

  factory DeletePhotoResponse.fromJson(Map<String, dynamic> json) =>
      _$DeletePhotoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DeletePhotoResponseToJson(this);
}