# Photo Upload API Documentation

This document outlines the photo upload and management endpoints for the WMS (Warehouse Management System) API.

## Overview

The photo upload system supports three types of photos:
- **`photoProof`** - Transaction photo proof
- **`transferProof`** - Transaction transfer proof  
- **`product`** - Product photos

All uploaded images are automatically converted to WebP format and stored in Cloudinary with year-based folder organization.

## Base URL

```
https://your-api-domain.com/api/v1/photos
```

## Authentication

All endpoints require JWT Bearer token authentication:

```http
Authorization: Bearer YOUR_JWT_TOKEN
```

## Folder Structure

Photos are organized in Cloudinary with the following structure:
- **Products**: `wms-products/2025/`
- **Transaction Photo Proof**: `wms-transactions/photoProof/2025/`
- **Transaction Transfer Proof**: `wms-transactions/transferProof/2025/`

---

## Endpoints

### 1. Upload Photo

Upload a new photo for a transaction or product.

**Endpoint:** `POST /photos`

**Content-Type:** `multipart/form-data`

**Form Fields:**
- `image` (File, required) - Image file to upload
- `type` (string, required) - Photo type: `photoProof`, `transferProof`, or `product`
- `transactionId` (string, optional) - Transaction ID (required for `photoProof` and `transferProof`)
- `productId` (string, optional) - Product ID (required for `product` type)

**Business Rules:**
- For `type=product`: `productId` is required, `transactionId` must be empty
- For `type=photoProof` or `type=transferProof`: `transactionId` is required, `productId` must be empty
- Only one of `transactionId` or `productId` can be specified
- Supported image formats: JPEG, PNG, GIF, BMP, TIFF, WebP
- Maximum file size: 10MB
- Images are automatically converted to WebP format

#### Request Example

```bash
curl -X POST https://your-api-domain.com/api/v1/photos \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -F "image=@/path/to/image.jpg" \
  -F "type=photoProof" \
  -F "transactionId=550e8400-e29b-41d4-a716-446655440000"
```

#### Response

**Success (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "photo_abc123",
    "publicId": "wms-transactions/photoProof/2025/abc123",
    "secureUrl": "https://res.cloudinary.com/your-cloud/image/upload/v123456/wms-transactions/photoProof/2025/abc123.webp",
    "type": "photoProof",
    "transactionId": "550e8400-e29b-41d4-a716-446655440000",
    "productId": null,
    "createdBy": "user_123",
    "createdAt": "2025-01-29T10:30:00.000Z",
    "updatedAt": "2025-01-29T10:30:00.000Z",
    "deletedAt": null
  }
}
```

**Error (400 Bad Request):**
```json
{
  "success": false,
  "message": "Image file is required"
}
```

**Error (403 Forbidden):**
```json
{
  "success": false,
  "message": "You don't have access to this transaction"
}
```

**Error (404 Not Found):**
```json
{
  "success": false,
  "message": "Transaction not found"
}
```

---

### 2. Get Photos by Transaction ID

Retrieve all photos for a specific transaction, optionally filtered by type.

**Endpoint:** `GET /photos/transaction/:id`

**Parameters:**
- `id` (path, required) - Transaction ID

**Query Parameters:**
- `type` (string, optional) - Filter by photo type: `photoProof` or `transferProof`

#### Request Examples

```bash
# Get all photos for a transaction
curl -X GET https://your-api-domain.com/api/v1/photos/transaction/550e8400-e29b-41d4-a716-446655440000 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Get only photo proof for a transaction
curl -X GET "https://your-api-domain.com/api/v1/photos/transaction/550e8400-e29b-41d4-a716-446655440000?type=photoProof" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Response

**Success (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "photo_abc123",
      "publicId": "wms-transactions/photoProof/2025/abc123",
      "secureUrl": "https://res.cloudinary.com/your-cloud/image/upload/v123456/wms-transactions/photoProof/2025/abc123.webp",
      "type": "photoProof",
      "transactionId": "550e8400-e29b-41d4-a716-446655440000",
      "productId": null,
      "createdBy": "user_123",
      "createdAt": "2025-01-29T10:30:00.000Z",
      "updatedAt": "2025-01-29T10:30:00.000Z",
      "deletedAt": null
    },
    {
      "id": "photo_def456",
      "publicId": "wms-transactions/transferProof/2025/def456",
      "secureUrl": "https://res.cloudinary.com/your-cloud/image/upload/v123456/wms-transactions/transferProof/2025/def456.webp",
      "type": "transferProof",
      "transactionId": "550e8400-e29b-41d4-a716-446655440000",
      "productId": null,
      "createdBy": "user_123",
      "createdAt": "2025-01-29T10:35:00.000Z",
      "updatedAt": "2025-01-29T10:35:00.000Z",
      "deletedAt": null
    }
  ]
}
```

**Error (404 Not Found):**
```json
{
  "success": false,
  "message": "Transaction not found"
}
```

---

### 3. Get Photos by Product ID

Retrieve all photos for a specific product.

**Endpoint:** `GET /photos/product/:id`

**Parameters:**
- `id` (path, required) - Product ID

**Query Parameters:**
- `type` (string, optional) - Filter by photo type (only `product` is valid)

#### Request Example

```bash
curl -X GET https://your-api-domain.com/api/v1/photos/product/prod_789xyz \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Response

**Success (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "photo_ghi789",
      "publicId": "wms-products/2025/ghi789",
      "secureUrl": "https://res.cloudinary.com/your-cloud/image/upload/v123456/wms-products/2025/ghi789.webp",
      "type": "product",
      "transactionId": null,
      "productId": "prod_789xyz",
      "createdBy": "user_123",
      "createdAt": "2025-01-29T11:00:00.000Z",
      "updatedAt": "2025-01-29T11:00:00.000Z",
      "deletedAt": null
    }
  ]
}
```

**Error (403 Forbidden):**
```json
{
  "success": false,
  "message": "You don't have access to photos for this product"
}
```

---

### 4. Update Photo by Transaction ID

Replace an existing transaction photo or create a new one if none exists.

**Endpoint:** `PUT /photos/transaction/:transactionId`

**Content-Type:** `multipart/form-data`

**Parameters:**
- `transactionId` (path, required) - Transaction ID

**Query Parameters:**
- `type` (string, required) - Photo type: `photoProof` or `transferProof`

**Form Fields:**
- `image` (File, required) - New image file to upload

**Behavior:**
- If a photo of the specified type exists, it will be replaced (old photo deleted from Cloudinary)
- If no photo of the specified type exists, a new one will be created
- The operation is atomic - if anything fails, no changes are made

#### Request Example

```bash
curl -X PUT "https://your-api-domain.com/api/v1/photos/transaction/550e8400-e29b-41d4-a716-446655440000?type=photoProof" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -F "image=@/path/to/new-image.jpg"
```

#### Response

**Success (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "photo_abc123",
    "publicId": "wms-transactions/photoProof/2025/new456",
    "secureUrl": "https://res.cloudinary.com/your-cloud/image/upload/v123456/wms-transactions/photoProof/2025/new456.webp",
    "type": "photoProof",
    "transactionId": "550e8400-e29b-41d4-a716-446655440000",
    "productId": null,
    "createdBy": "user_123",
    "createdAt": "2025-01-29T10:30:00.000Z",
    "updatedAt": "2025-01-29T12:00:00.000Z",
    "deletedAt": null
  }
}
```

**Error (400 Bad Request):**
```json
{
  "success": false,
  "message": "Photo type is required"
}
```

---

### 5. Update Photo by Product ID

Replace an existing product photo or create a new one if none exists.

**Endpoint:** `PUT /photos/product/:productId`

**Content-Type:** `multipart/form-data`

**Parameters:**
- `productId` (path, required) - Product ID

**Form Fields:**
- `image` (File, required) - New image file to upload

**Behavior:**
- If a product photo exists, it will be replaced (old photo deleted from Cloudinary)
- If no product photo exists, a new one will be created
- The operation is atomic - if anything fails, no changes are made

#### Request Example

```bash
curl -X PUT https://your-api-domain.com/api/v1/photos/product/prod_789xyz \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -F "image=@/path/to/new-product-image.jpg"
```

#### Response

**Success (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "photo_ghi789",
    "publicId": "wms-products/2025/updated123",
    "secureUrl": "https://res.cloudinary.com/your-cloud/image/upload/v123456/wms-products/2025/updated123.webp",
    "type": "product",
    "transactionId": null,
    "productId": "prod_789xyz",
    "createdBy": "user_123",
    "createdAt": "2025-01-29T11:00:00.000Z",
    "updatedAt": "2025-01-29T12:30:00.000Z",
    "deletedAt": null
  }
}
```

---

### 6. Delete Photo

Soft delete a photo and remove it from Cloudinary.

**Endpoint:** `DELETE /photos/:id`

**Parameters:**
- `id` (path, required) - Photo ID

#### Request Example

```bash
curl -X DELETE https://your-api-domain.com/api/v1/photos/photo_abc123 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Response

**Success (200 OK):**
```json
{
  "success": true,
  "data": {
    "message": "Photo deleted successfully"
  }
}
```

**Error (403 Forbidden):**
```json
{
  "success": false,
  "message": "You don't have permission to delete this photo"
}
```

**Error (404 Not Found):**
```json
{
  "success": false,
  "message": "Photo not found"
}
```

---

## Authorization Rules

### Role-Based Access Control

- **OWNER**: Full access to all photos across all stores
- **ADMIN/STAFF/CASHIER**: Access limited to photos related to their assigned store

### Photo Access Rules

1. **Transaction Photos**: User must have access to the transaction (based on store ownership/assignment)
2. **Product Photos**: User must have access to the product's store
3. **Photo Deletion**: 
   - OWNER role can delete any photo
   - Other roles can only delete photos they created

### Store Scoping

Non-owner users can only:
- Upload photos for transactions/products in their assigned store
- View photos for transactions/products in their assigned store
- Delete photos they created in their assigned store

---

## Error Handling

### Common HTTP Status Codes

- **200 OK**: Request successful
- **201 Created**: Photo uploaded successfully
- **400 Bad Request**: Invalid request data or validation error
- **401 Unauthorized**: Missing or invalid JWT token
- **403 Forbidden**: User doesn't have permission for the requested resource
- **404 Not Found**: Requested resource (photo, transaction, product) not found
- **413 Payload Too Large**: Image file exceeds 10MB limit
- **422 Unprocessable Entity**: Invalid image format
- **500 Internal Server Error**: Server error

### Error Response Format

All error responses follow this format:

```json
{
  "success": false,
  "message": "Error description"
}
```

### Validation Errors

Common validation error messages:

- `"Image file is required"`
- `"Photo type is required"`
- `"Either transactionId or productId must be provided"`
- `"Cannot specify both transactionId and productId"`
- `"File must be an image"`
- `"Transaction not found"`
- `"Product not found"`
- `"You don't have access to this transaction"`
- `"You don't have access to photos for this product"`
- `"You don't have permission to delete this photo"`

---

## Technical Implementation

### Image Processing

1. **Format Conversion**: All uploaded images are automatically converted to WebP format using Sharp.js
2. **Optimization**: Images are optimized for web delivery with quality settings
3. **Resize**: Large images are automatically resized to maximum dimensions of 1200x1200px while maintaining aspect ratio
4. **Validation**: File type, size, and format validation before processing

### Storage

1. **Cloudinary Integration**: Images are stored in Cloudinary cloud storage
2. **Year-Based Organization**: Automatic folder organization by current year
3. **Secure URLs**: All image URLs are secure HTTPS URLs from Cloudinary CDN
4. **Cleanup**: When photos are deleted, they are removed from both database and Cloudinary

### Database Schema

Photos are stored with the following structure:

```sql
CREATE TABLE photos (
  id TEXT PRIMARY KEY,
  public_id TEXT NOT NULL,      -- Cloudinary public_id
  secure_url TEXT NOT NULL,     -- Cloudinary secure_url  
  type TEXT NOT NULL,           -- photoProof|transferProof|product
  transaction_id TEXT,          -- FK to transactions (optional)
  product_id TEXT,              -- FK to products (optional)
  created_by TEXT NOT NULL,     -- FK to users
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER            -- Soft delete
);
```

---

## Rate Limiting

Currently, no specific rate limiting is implemented for photo upload endpoints. However, it's recommended to implement rate limiting in production environments to prevent abuse.

## Security Considerations

1. **File Type Validation**: Only image files are accepted
2. **File Size Limits**: Maximum 10MB file size
3. **Authentication Required**: All endpoints require valid JWT token
4. **Authorization Checks**: Role-based and store-scoped access control
5. **Input Sanitization**: All inputs are validated and sanitized
6. **Secure Storage**: Images stored in Cloudinary with secure URLs

---

## SDKs and Integration

### JavaScript/TypeScript

```typescript
// Upload product photo
const formData = new FormData();
formData.append('image', imageFile);
formData.append('type', 'product');
formData.append('productId', 'prod_123');

const response = await fetch('/api/v1/photos', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});

const result = await response.json();
```

### cURL Examples

All cURL examples are provided in the endpoint sections above.

---

## Changelog

- **v1.0.0** (2025-01-29): Initial implementation with photo upload, retrieval, update, and delete functionality
- Support for three photo types: photoProof, transferProof, product
- Year-based folder organization in Cloudinary
- Role-based access control and store scoping
- Automatic WebP conversion and image optimization