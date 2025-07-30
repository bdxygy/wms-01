import { v2 as cloudinary, UploadApiResponse, UploadApiErrorResponse } from 'cloudinary';
import { HTTPException } from 'hono/http-exception';
import { env } from '../config/env';
import { ImageProcessor, type ProcessedImage } from '../utils/image-processing';

export interface CloudinaryUploadOptions {
  folder?: string;
  publicId?: string;
  tags?: string[];
  transformation?: any;
}

export interface CloudinaryUploadResult {
  publicId: string;
  secureUrl: string;
  url: string;
  format: string;
  width: number;
  height: number;
  bytes: number;
  createdAt: string;
}

export class CloudinaryService {
  private static isConfigured = false;

  /**
   * Generate year-based folder path for WMS photos
   * 
   * Examples:
   * - 'wms-products' → 'wms-products/2025'
   * - 'wms-transactions/photoProof' → 'wms-transactions/photoProof/2025'
   * - 'wms-transactions/transferProof' → 'wms-transactions/transferProof/2025'
   */
  static generateYearBasedFolder(baseFolder: string): string {
    const currentYear = new Date().getFullYear();
    return `${baseFolder}/${currentYear}`;
  }

  /**
   * Initialize Cloudinary configuration
   */
  private static ensureConfigured(): void {
    if (!this.isConfigured) {
      cloudinary.config({
        cloud_name: env.CLOUDINARY_CLOUD_NAME,
        api_key: env.CLOUDINARY_API_KEY,
        api_secret: env.CLOUDINARY_API_SECRET,
        secure: true // Always use HTTPS
      });
      this.isConfigured = true;
    }
  }

  /**
   * Upload processed image buffer to Cloudinary
   */
  static async uploadImage(
    imageBuffer: Buffer,
    options: CloudinaryUploadOptions = {}
  ): Promise<CloudinaryUploadResult> {
    this.ensureConfigured();

    try {
      // Process image to WebP format
      const processedImage: ProcessedImage = await ImageProcessor.processToWebP(imageBuffer);

      // Prepare upload options
      const uploadOptions = {
        resource_type: 'image' as const,
        format: 'webp', // Ensure WebP format
        folder: options.folder || 'wms-photos',
        public_id: options.publicId,
        tags: options.tags || ['wms', 'photo'],
        transformation: options.transformation,
        overwrite: false, // Don't overwrite existing files
        unique_filename: true, // Generate unique filename if public_id not provided
        use_filename: false, // Don't use original filename
      };

      // Upload to Cloudinary
      const result = await new Promise<UploadApiResponse>((resolve, reject) => {
        cloudinary.uploader.upload_stream(
          uploadOptions,
          (error: UploadApiErrorResponse | undefined, result: UploadApiResponse | undefined) => {
            if (error) {
              reject(error);
            } else if (result) {
              resolve(result);
            } else {
              reject(new Error('Upload failed with no result'));
            }
          }
        ).end(processedImage.buffer);
      });

      return {
        publicId: result.public_id,
        secureUrl: result.secure_url,
        url: result.url,
        format: result.format,
        width: result.width,
        height: result.height,
        bytes: result.bytes,
        createdAt: result.created_at
      };

    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }

      // Handle Cloudinary-specific errors
      if (error && typeof error === 'object' && 'error' in error) {
        const cloudinaryError = error as any;
        if (cloudinaryError.error?.message) {
          throw new HTTPException(400, { 
            message: `Cloudinary upload failed: ${cloudinaryError.error.message}` 
          });
        }
      }

      console.error('Cloudinary upload error:', error);
      throw new HTTPException(500, { message: 'Failed to upload image to cloud storage' });
    }
  }

  /**
   * Delete image from Cloudinary
   */
  static async deleteImage(publicId: string): Promise<{ result: string }> {
    this.ensureConfigured();

    try {
      const result = await cloudinary.uploader.destroy(publicId, {
        resource_type: 'image'
      });

      if (result.result === 'not found') {
        throw new HTTPException(404, { message: 'Image not found in cloud storage' });
      }

      if (result.result !== 'ok') {
        throw new HTTPException(400, { message: 'Failed to delete image from cloud storage' });
      }

      return result;
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }

      console.error('Cloudinary delete error:', error);
      throw new HTTPException(500, { message: 'Failed to delete image from cloud storage' });
    }
  }

  /**
   * Get image information from Cloudinary
   */
  static async getImageInfo(publicId: string) {
    this.ensureConfigured();

    try {
      const result = await cloudinary.api.resource(publicId, {
        resource_type: 'image'
      });

      return {
        publicId: result.public_id,
        secureUrl: result.secure_url,
        url: result.url,
        format: result.format,
        width: result.width,
        height: result.height,
        bytes: result.bytes,
        createdAt: result.created_at,
        tags: result.tags
      };
    } catch (error) {
      if (error && typeof error === 'object' && 'error' in error) {
        const cloudinaryError = error as any;
        if (cloudinaryError.error?.http_code === 404) {
          throw new HTTPException(404, { message: 'Image not found in cloud storage' });
        }
      }

      console.error('Cloudinary get info error:', error);
      throw new HTTPException(500, { message: 'Failed to get image information from cloud storage' });
    }
  }

  /**
   * Generate transformation URL for image optimization
   */
  static generateOptimizedUrl(
    publicId: string, 
    options: {
      width?: number;
      height?: number;
      quality?: number;
      format?: string;
    } = {}
  ): string {
    this.ensureConfigured();

    const transformation = [];

    if (options.width || options.height) {
      transformation.push({
        width: options.width,
        height: options.height,
        crop: 'limit'
      });
    }

    if (options.quality) {
      transformation.push({ quality: options.quality });
    }

    if (options.format) {
      transformation.push({ format: options.format });
    }

    return cloudinary.url(publicId, {
      secure: true,
      transformation: transformation.length > 0 ? transformation : undefined
    });
  }
}