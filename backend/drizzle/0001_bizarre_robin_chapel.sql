CREATE UNIQUE INDEX `unique_sku_per_store` ON `products` (`sku`,`store_id`);--> statement-breakpoint
CREATE UNIQUE INDEX `unique_barcode` ON `products` (`barcode`);