import sharp from 'sharp';
import { HTTPException } from 'hono/http-exception';

export interface ImageProcessingOptions {
  maxWidth?: number;
  maxHeight?: number;
  quality?: number;
}

export interface ProcessedImage {
  buffer: Buffer;
  format: string;
  size: number;
  width: number;
  height: number;
}

export class ImageProcessor {
  private static readonly DEFAULT_MAX_WIDTH = 1200;
  private static readonly DEFAULT_MAX_HEIGHT = 1200;
  private static readonly DEFAULT_QUALITY = 85;
  private static readonly MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
  
  private static readonly ALLOWED_FORMATS = [
    'jpeg', 'jpg', 'png', 'gif', 'bmp', 'tiff', 'webp'
  ];

  /**
   * Process and convert image to WebP format with optimization
   */
  static async processToWebP(
    imageBuffer: Buffer, 
    options: ImageProcessingOptions = {}
  ): Promise<ProcessedImage> {
    try {
      // Validate file size
      if (imageBuffer.length > this.MAX_FILE_SIZE) {
        throw new HTTPException(400, { 
          message: `File size exceeds maximum limit of ${this.MAX_FILE_SIZE / (1024 * 1024)}MB` 
        });
      }

      // Get image metadata first
      const metadata = await sharp(imageBuffer).metadata();
      
      if (!metadata.format) {
        throw new HTTPException(400, { message: 'Invalid image format' });
      }

      // Check if format is supported
      if (!this.ALLOWED_FORMATS.includes(metadata.format.toLowerCase())) {
        throw new HTTPException(400, { 
          message: `Unsupported image format: ${metadata.format}. Allowed formats: ${this.ALLOWED_FORMATS.join(', ')}` 
        });
      }

      const {
        maxWidth = this.DEFAULT_MAX_WIDTH,
        maxHeight = this.DEFAULT_MAX_HEIGHT,
        quality = this.DEFAULT_QUALITY
      } = options;

      // Process image
      let sharpInstance = sharp(imageBuffer);

      // Resize if needed (maintain aspect ratio)
      if (metadata.width && metadata.height) {
        if (metadata.width > maxWidth || metadata.height > maxHeight) {
          sharpInstance = sharpInstance.resize(maxWidth, maxHeight, {
            fit: 'inside',
            withoutEnlargement: true
          });
        }
      }

      // Convert to WebP with quality settings
      const processedBuffer = await sharpInstance
        .webp({ 
          quality,
          effort: 6, // Higher effort for better compression
          lossless: false
        })
        .toBuffer({ resolveWithObject: true });

      return {
        buffer: processedBuffer.data,
        format: 'webp',
        size: processedBuffer.data.length,
        width: processedBuffer.info.width,
        height: processedBuffer.info.height
      };

    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      
      // Handle Sharp-specific errors
      if (error instanceof Error) {
        if (error.message.includes('Input buffer contains unsupported image format')) {
          throw new HTTPException(400, { message: 'Unsupported or corrupted image format' });
        }
        if (error.message.includes('Input image exceeds pixel limit')) {
          throw new HTTPException(400, { message: 'Image dimensions too large' });
        }
      }

      throw new HTTPException(500, { message: 'Image processing failed' });
    }
  }

  /**
   * Get image metadata without processing
   */
  static async getImageMetadata(imageBuffer: Buffer) {
    try {
      const metadata = await sharp(imageBuffer).metadata();
      
      return {
        format: metadata.format,
        width: metadata.width,
        height: metadata.height,
        size: imageBuffer.length,
        hasAlpha: metadata.hasAlpha,
        density: metadata.density
      };
    } catch (error) {
      throw new HTTPException(400, { message: 'Failed to read image metadata' });
    }
  }

  /**
   * Validate image format and size before processing
   */
  static validateImage(imageBuffer: Buffer): void {
    if (!imageBuffer || imageBuffer.length === 0) {
      throw new HTTPException(400, { message: 'No image data provided' });
    }

    if (imageBuffer.length > this.MAX_FILE_SIZE) {
      throw new HTTPException(400, { 
        message: `File size exceeds maximum limit of ${this.MAX_FILE_SIZE / (1024 * 1024)}MB` 
      });
    }
  }
}