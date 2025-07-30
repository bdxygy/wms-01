import { randomUUID } from "crypto";
import { and, eq, isNull } from "drizzle-orm";
import { HTTPException } from "hono/http-exception";
import { db } from "../config/database";
import { photos, type PhotoType } from "../models/photos";
import { products } from "../models/products";
import { stores } from "../models/stores";
import { transactions } from "../models/transactions";
import type { User } from "../models/users";
import { CloudinaryService } from "./cloudinary.service";

export interface CreatePhotoRequest {
  imageBuffer: Buffer;
  type: PhotoType;
  transactionId?: string;
  productId?: string;
}

export interface UpdatePhotoRequest {
  publicId?: string;
  secureUrl?: string;
}

export interface UpdatePhotoByTransactionRequest {
  imageBuffer: Buffer;
  type: PhotoType;
}

export interface UpdatePhotoByProductRequest {
  imageBuffer: Buffer;
}

export class PhotoService {
  static async createPhoto(data: CreatePhotoRequest, createdBy: User) {
    // Validate that either transactionId or productId is provided, but not both
    if (!data.transactionId && !data.productId) {
      throw new HTTPException(400, { 
        message: "Either transactionId or productId must be provided" 
      });
    }

    if (data.transactionId && data.productId) {
      throw new HTTPException(400, { 
        message: "Cannot specify both transactionId and productId" 
      });
    }

    // Validate photo type based on context
    if (data.productId && data.type !== 'product') {
      throw new HTTPException(400, { 
        message: "Photo type must be 'product' when productId is provided" 
      });
    }

    if (data.transactionId && data.type === 'product') {
      throw new HTTPException(400, { 
        message: "Photo type cannot be 'product' when transactionId is provided" 
      });
    }

    if (data.transactionId && !['photoProof', 'transferProof'].includes(data.type)) {
      throw new HTTPException(400, { 
        message: "Photo type must be 'photoProof' or 'transferProof' when transactionId is provided" 
      });
    }

    // Verify transaction exists and user has access (if transactionId provided)
    if (data.transactionId) {
      const transaction = await db
        .select()
        .from(transactions)
        .where(eq(transactions.id, data.transactionId));

      if (!transaction[0]) {
        throw new HTTPException(404, { message: "Transaction not found" });
      }
    }

    // Verify product exists and user has access (if productId provided)
    if (data.productId) {
      const product = await db
        .select({
          id: products.id,
          storeId: products.storeId,
          storeOwnerId: stores.ownerId,
        })
        .from(products)
        .innerJoin(stores, eq(products.storeId, stores.id))
        .where(
          and(
            eq(products.id, data.productId),
            isNull(products.deletedAt)
          )
        );

      if (!product[0]) {
        throw new HTTPException(404, { message: "Product not found" });
      }

      // Check if user has access to the product's store through owner hierarchy
      if (createdBy.role === 'OWNER') {
        if (product[0].storeOwnerId !== createdBy.id) {
          throw new HTTPException(403, { 
            message: "You don't have access to photos for this product" 
          });
        }
      } else {
        if (product[0].storeOwnerId !== createdBy.ownerId) {
          throw new HTTPException(403, { 
            message: "You don't have access to photos for this product" 
          });
        }
      }
    }

    try {
      // Upload image to Cloudinary with processing - organize by type and year
      const baseFolder = data.type === 'product' ? 'wms-products' : `wms-transactions/${data.type}`;
      const folderName = CloudinaryService.generateYearBasedFolder(baseFolder);
      const uploadResult = await CloudinaryService.uploadImage(data.imageBuffer, {
        folder: folderName,
        tags: [
          'wms',
          data.type,
          data.transactionId || data.productId || 'unknown'
        ]
      });

      const photoId = randomUUID();
      const newPhoto = {
        id: photoId,
        publicId: uploadResult.publicId,
        secureUrl: uploadResult.secureUrl,
        type: data.type,
        transactionId: data.transactionId || null,
        productId: data.productId || null,
        createdBy: createdBy.id,
      };

      await db.insert(photos).values(newPhoto);

      return await db
        .select()
        .from(photos)
        .where(eq(photos.id, photoId));
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      console.error('Photo creation error:', error);
      throw new HTTPException(500, { message: 'Failed to create photo' });
    }
  }

  static async getPhotosByTransaction(transactionId: string, user: User, photoType?: PhotoType) {
    // Verify transaction exists
    const transaction = await db
      .select()
      .from(transactions)
      .where(eq(transactions.id, transactionId));

    if (!transaction[0]) {
      throw new HTTPException(404, { message: "Transaction not found" });
    }

    // Build where conditions
    const whereConditions = [
      eq(photos.transactionId, transactionId),
      isNull(photos.deletedAt)
    ];

    // Add type filter if provided
    if (photoType) {
      // Validate that the photo type is valid for transactions
      if (photoType === 'product') {
        throw new HTTPException(400, { 
          message: "Photo type 'product' is not valid for transaction photos" 
        });
      }
      whereConditions.push(eq(photos.type, photoType));
    }

    return await db
      .select()
      .from(photos)
      .where(and(...whereConditions));
  }

  static async getPhotosByProduct(productId: string, user: User, photoType?: PhotoType) {
    // Verify product exists and user has access
    const product = await db
      .select({
        id: products.id,
        storeId: products.storeId,
        storeOwnerId: stores.ownerId,
      })
      .from(products)
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(
        and(
          eq(products.id, productId),
          isNull(products.deletedAt)
        )
      );

    if (!product[0]) {
      throw new HTTPException(404, { message: "Product not found" });
    }

    // Check if user has access to the product's store through owner hierarchy
    if (user.role === 'OWNER') {
      if (product[0].storeOwnerId !== user.id) {
        throw new HTTPException(403, { 
          message: "You don't have access to photos for this product" 
        });
      }
    } else {
      if (product[0].storeOwnerId !== user.ownerId) {
        throw new HTTPException(403, { 
          message: "You don't have access to photos for this product" 
        });
      }
    }

    // Build where conditions
    const whereConditions = [
      eq(photos.productId, productId),
      isNull(photos.deletedAt)
    ];

    // Add type filter if provided
    if (photoType) {
      // Validate that the photo type is valid for products
      if (photoType !== 'product') {
        throw new HTTPException(400, { 
          message: "Only photo type 'product' is valid for product photos" 
        });
      }
      whereConditions.push(eq(photos.type, photoType));
    }

    return await db
      .select()
      .from(photos)
      .where(and(...whereConditions));
  }

  static async deletePhoto(photoId: string, user: User) {
    const photo = await db
      .select()
      .from(photos)
      .where(
        and(
          eq(photos.id, photoId),
          isNull(photos.deletedAt)
        )
      );

    if (!photo[0]) {
      throw new HTTPException(404, { message: "Photo not found" });
    }

    // Check if user has permission to delete the photo
    if (user.role !== 'OWNER' && photo[0].createdBy !== user.id) {
      throw new HTTPException(403, { 
        message: "You don't have permission to delete this photo" 
      });
    }

    try {
      // Delete from Cloudinary first
      await CloudinaryService.deleteImage(photo[0].publicId);

      // Soft delete from database
      await db
        .update(photos)
        .set({ 
          deletedAt: new Date(),
          updatedAt: new Date()
        })
        .where(eq(photos.id, photoId));

      return { message: "Photo deleted successfully" };
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      console.error('Photo deletion error:', error);
      throw new HTTPException(500, { message: 'Failed to delete photo' });
    }
  }

  static async updatePhotoByTransaction(transactionId: string, data: UpdatePhotoByTransactionRequest, user: User) {
    // Validate photo type for transactions
    if (data.type === 'product') {
      throw new HTTPException(400, { 
        message: "Photo type 'product' is not valid for transaction photos" 
      });
    }

    if (!['photoProof', 'transferProof'].includes(data.type)) {
      throw new HTTPException(400, { 
        message: "Photo type must be 'photoProof' or 'transferProof' when updating transaction photos" 
      });
    }

    // Verify transaction exists
    const transaction = await db
      .select()
      .from(transactions)
      .where(eq(transactions.id, transactionId));

    if (!transaction[0]) {
      throw new HTTPException(404, { message: "Transaction not found" });
    }

    try {
      // Find existing photo by transaction ID and type
      const existingPhoto = await db
        .select()
        .from(photos)
        .where(
          and(
            eq(photos.transactionId, transactionId),
            eq(photos.type, data.type),
            isNull(photos.deletedAt)
          )
        );

      let oldPublicId: string | null = null;
      
      // If existing photo found, prepare for cleanup
      if (existingPhoto[0]) {
        oldPublicId = existingPhoto[0].publicId;
      }

      // Upload new image to Cloudinary with processing - organize by type and year
      const baseFolder = `wms-transactions/${data.type}`;
      const folderName = CloudinaryService.generateYearBasedFolder(baseFolder);
      const uploadResult = await CloudinaryService.uploadImage(data.imageBuffer, {
        folder: folderName,
        tags: [
          'wms',
          data.type,
          transactionId
        ]
      });

      // Update or create photo record
      if (existingPhoto[0]) {
        // Update existing photo
        await db
          .update(photos)
          .set({
            publicId: uploadResult.publicId,
            secureUrl: uploadResult.secureUrl,
            updatedAt: new Date()
          })
          .where(eq(photos.id, existingPhoto[0].id));

        // Clean up old Cloudinary image after successful database update
        if (oldPublicId) {
          try {
            await CloudinaryService.deleteImage(oldPublicId);
          } catch (cleanupError) {
            // Log cleanup error but don't fail the request
            console.error('Failed to cleanup old Cloudinary image:', cleanupError);
          }
        }

        // Return updated photo
        return await db
          .select()
          .from(photos)
          .where(eq(photos.id, existingPhoto[0].id));
      } else {
        // Create new photo
        const photoId = randomUUID();
        const newPhoto = {
          id: photoId,
          publicId: uploadResult.publicId,
          secureUrl: uploadResult.secureUrl,
          type: data.type,
          transactionId: transactionId,
          productId: null,
          createdBy: user.id,
        };

        await db.insert(photos).values(newPhoto);

        return await db
          .select()
          .from(photos)
          .where(eq(photos.id, photoId));
      }
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      console.error('Photo update error:', error);
      throw new HTTPException(500, { message: 'Failed to update photo' });
    }
  }

  static async updatePhotoByProduct(productId: string, data: UpdatePhotoByProductRequest, user: User) {
    // Verify product exists and user has access
    const product = await db
      .select({
        id: products.id,
        storeId: products.storeId,
        storeOwnerId: stores.ownerId,
      })
      .from(products)
      .innerJoin(stores, eq(products.storeId, stores.id))
      .where(
        and(
          eq(products.id, productId),
          isNull(products.deletedAt)
        )
      );

    if (!product[0]) {
      throw new HTTPException(404, { message: "Product not found" });
    }

    // Check if user has access to the product's store through owner hierarchy
    if (user.role === 'OWNER') {
      if (product[0].storeOwnerId !== user.id) {
        throw new HTTPException(403, { 
          message: "You don't have access to photos for this product" 
        });
      }
    } else {
      if (product[0].storeOwnerId !== user.ownerId) {
        throw new HTTPException(403, { 
          message: "You don't have access to photos for this product" 
        });
      }
    }

    try {
      // Find existing photo by product ID
      const existingPhoto = await db
        .select()
        .from(photos)
        .where(
          and(
            eq(photos.productId, productId),
            eq(photos.type, 'product'),
            isNull(photos.deletedAt)
          )
        );

      let oldPublicId: string | null = null;
      
      // If existing photo found, prepare for cleanup
      if (existingPhoto[0]) {
        oldPublicId = existingPhoto[0].publicId;
      }

      // Upload new image to Cloudinary with processing - organize by year
      const baseFolder = 'wms-products';
      const folderName = CloudinaryService.generateYearBasedFolder(baseFolder);
      const uploadResult = await CloudinaryService.uploadImage(data.imageBuffer, {
        folder: folderName,
        tags: [
          'wms',
          'product',
          productId
        ]
      });

      // Update or create photo record
      if (existingPhoto[0]) {
        // Update existing photo
        await db
          .update(photos)
          .set({
            publicId: uploadResult.publicId,
            secureUrl: uploadResult.secureUrl,
            updatedAt: new Date()
          })
          .where(eq(photos.id, existingPhoto[0].id));

        // Clean up old Cloudinary image after successful database update
        if (oldPublicId) {
          try {
            await CloudinaryService.deleteImage(oldPublicId);
          } catch (cleanupError) {
            // Log cleanup error but don't fail the request
            console.error('Failed to cleanup old Cloudinary image:', cleanupError);
          }
        }

        // Return updated photo
        return await db
          .select()
          .from(photos)
          .where(eq(photos.id, existingPhoto[0].id));
      } else {
        // Create new photo
        const photoId = randomUUID();
        const newPhoto = {
          id: photoId,
          publicId: uploadResult.publicId,
          secureUrl: uploadResult.secureUrl,
          type: 'product' as PhotoType,
          transactionId: null,
          productId: productId,
          createdBy: user.id,
        };

        await db.insert(photos).values(newPhoto);

        return await db
          .select()
          .from(photos)
          .where(eq(photos.id, photoId));
      }
    } catch (error) {
      if (error instanceof HTTPException) {
        throw error;
      }
      console.error('Photo update error:', error);
      throw new HTTPException(500, { message: 'Failed to update photo' });
    }
  }
}