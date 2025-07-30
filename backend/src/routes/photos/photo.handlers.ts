import { Context } from "hono";
import { PhotoService } from "../../services/photo.service";
import { ResponseUtils } from "../../utils/responses";
import type { User } from "../../models/users";
import type { PhotoType } from "../../models/photos";

/**
 * Upload photo handler - handles multipart form data with image file
 */
export const uploadPhotoHandler = async (c: Context) => {
  try {
    const user = c.get("user") as User;

    // Parse multipart form data
    const body = await c.req.parseBody();
    
    // Get the image file
    const imageFile = body['image'] as File;
    if (!imageFile) {
      return ResponseUtils.sendError(c, new Error("Image file is required"));
    }

    // Validate file type
    if (!imageFile.type.startsWith('image/')) {
      return ResponseUtils.sendError(c, new Error("File must be an image"));
    }

    // Convert File to Buffer and process with Sharp
    const arrayBuffer = await imageFile.arrayBuffer();
    const originalBuffer = Buffer.from(arrayBuffer);
    
    // Process image with Sharp: resize to max height 600px, auto width, WebP format, 50% quality
    const sharp = require('sharp');
    const imageBuffer = await sharp(originalBuffer)
      .resize({ height: 600, withoutEnlargement: true })
      .webp({ quality: 50 })
      .toBuffer();

    // Get form data
    const type = body['type'] as PhotoType;
    const transactionId = body['transactionId'] as string;
    const productId = body['productId'] as string;

    // Validate required type field
    if (!type) {
      return ResponseUtils.sendError(c, new Error("Photo type is required"));
    }

    // Validate that either transactionId or productId is provided
    if (!transactionId && !productId) {
      return ResponseUtils.sendError(c, new Error("Either transactionId or productId must be provided"));
    }

    if (transactionId && productId) {
      return ResponseUtils.sendError(c, new Error("Cannot specify both transactionId and productId"));
    }

    // Create photo with image processing and Cloudinary upload
    const photo = await PhotoService.createPhoto({
      imageBuffer,
      type,
      transactionId: transactionId || undefined,
      productId: productId || undefined,
    }, user);

    return ResponseUtils.sendCreated(c, photo[0]);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

/**
 * Get photos by transaction ID handler
 */
export const getPhotosByTransactionHandler = async (c: Context) => {
  try {
    const user = c.get("user") as User;
    const { id: transactionId } = c.req.param();
    const { type } = c.req.query();

    const photos = await PhotoService.getPhotosByTransaction(
      transactionId, 
      user, 
      type as PhotoType | undefined
    );

    return ResponseUtils.sendSuccess(c, photos);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

/**
 * Get photos by product ID handler
 */
export const getPhotosByProductHandler = async (c: Context) => {
  try {
    const user = c.get("user") as User;
    const { id: productId } = c.req.param();
    const { type } = c.req.query();

    const photos = await PhotoService.getPhotosByProduct(
      productId, 
      user, 
      type as PhotoType | undefined
    );

    return ResponseUtils.sendSuccess(c, photos);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

/**
 * Delete photo handler
 */
export const deletePhotoHandler = async (c: Context) => {
  try {
    const user = c.get("user") as User;
    const { id: photoId } = c.req.param();

    const result = await PhotoService.deletePhoto(photoId, user);

    return ResponseUtils.sendSuccess(c, result);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

/**
 * Update photo by transaction ID handler - replaces existing photo or creates new one
 */
export const updatePhotoByTransactionHandler = async (c: Context) => {
  try {
    const user = c.get("user") as User;
    const { transactionId } = c.req.param();

    // Parse multipart form data
    const body = await c.req.parseBody();
    
    // Get the image file
    const imageFile = body['image'] as File;
    if (!imageFile) {
      return ResponseUtils.sendError(c, new Error("Image file is required"));
    }

    // Validate file type
    if (!imageFile.type.startsWith('image/')) {
      return ResponseUtils.sendError(c, new Error("File must be an image"));
    }

    // Convert File to Buffer and process with Sharp
    const arrayBuffer = await imageFile.arrayBuffer();
    const originalBuffer = Buffer.from(arrayBuffer);
    
    // Process image with Sharp: resize to max height 600px, auto width, WebP format, 50% quality
    const sharp = require('sharp');
    const imageBuffer = await sharp(originalBuffer)
      .resize({ height: 600, withoutEnlargement: true })
      .webp({ quality: 50 })
      .toBuffer();

    // Get photo type from query parameter
    const { type } = c.req.query();
    if (!type) {
      return ResponseUtils.sendError(c, new Error("Photo type query parameter is required"));
    }

    // Validate photo type
    if (!['photoProof', 'transferProof'].includes(type)) {
      return ResponseUtils.sendError(c, new Error("Photo type must be 'photoProof' or 'transferProof'"));
    }

    // Update or create photo
    const photo = await PhotoService.updatePhotoByTransaction(transactionId, {
      imageBuffer,
      type: type as PhotoType,
    }, user);

    return ResponseUtils.sendSuccess(c, photo[0]);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};

/**
 * Update photo by product ID handler - replaces existing photo or creates new one
 */
export const updatePhotoByProductHandler = async (c: Context) => {
  try {
    const user = c.get("user") as User;
    const { productId } = c.req.param();

    // Parse multipart form data
    const body = await c.req.parseBody();
    
    // Get the image file
    const imageFile = body['image'] as File;
    if (!imageFile) {
      return ResponseUtils.sendError(c, new Error("Image file is required"));
    }

    // Validate file type
    if (!imageFile.type.startsWith('image/')) {
      return ResponseUtils.sendError(c, new Error("File must be an image"));
    }

    // Convert File to Buffer and process with Sharp
    const arrayBuffer = await imageFile.arrayBuffer();
    const originalBuffer = Buffer.from(arrayBuffer);
    
    // Process image with Sharp: resize to max height 600px, auto width, WebP format, 50% quality
    const sharp = require('sharp');
    const imageBuffer = await sharp(originalBuffer)
      .resize({ height: 600, withoutEnlargement: true })
      .webp({ quality: 50 })
      .toBuffer();

    // Update or create photo
    const photo = await PhotoService.updatePhotoByProduct(productId, {
      imageBuffer,
    }, user);

    return ResponseUtils.sendSuccess(c, photo[0]);
  } catch (error) {
    return ResponseUtils.sendError(c, error);
  }
};