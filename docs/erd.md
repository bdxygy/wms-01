// Project: Warehouse Management System
// Tool: dbdiagram.io

Enum user_role {
  OWNER
  ADMIN
  STAFF
  CASHIER
}

Enum transaction_type {
  SALE
  TRANSFER
}

Enum check_status_role {
    OK
    PENDING
    MISSING
    BROKEN
}

Table users {
  id uuid [pk, default: uuid_generate_v4()]
  owner_id uuid [ref: > users.id, null] // null if role is OWNER
  name varchar
  username varchar [unique]
  password_hash varchar
  role user_role
  created_at timestamp [default: now()]
  updated_at timestamp [default: now()]
  deleted_at timestamp [null]
}

Table stores {
  id uuid [pk, default: uuid_generate_v4()]
  owner_id uuid [ref: > users.id]
  name varchar
  code varchar [unique]
  type varchar
  address_line1 varchar
  address_line2 varchar [null]
  city varchar
  province varchar
  postal_code varchar
  country varchar
  phone_number varchar
  email varchar [null]
  is_active boolean [default: true]
  open_time timestamp
  close_time timestamp
  timezone varchar [default: 'Asia/Jakarta']
  map_location text
  created_by uuid [ref: > users.id]
  created_at timestamp [default: now()]
  updated_at timestamp [default: now()]
  deleted_at timestamp [null]
}

Table categories {
  id uuid [pk, default: uuid_generate_v4()]
  created_by uuid [ref: > users.id] // MUST OWNER or ADMIN
  name varchar
  description text [null]
  created_at timestamp [default: now()]
  updated_at timestamp [default: now()]
  deleted_at timestamp [null]
}

Table products {
  id uuid [pk, default: uuid_generate_v4()]
  created_by uuid [ref: > users.id] // MUST OWNER or ADMIN
  store_id uuid [ref: > stores.id]
  name varchar
  category_id uuid [ref: > categories.id]
  sku varchar
  is_imei boolean [default: false]
  barcode varchar
  quantity int [default: 1]
  purchase_price numeric(12,2)
  sale_price numeric(12,2) [null]
  created_at timestamp [default: now()]
  updated_at timestamp [default: now()]
  deleted_at timestamp [null]
}

Table product_imeis {
  id uuid [pk, default: uuid_generate_v4()]
  product_id uuid [ref: > products.id]
  imei varchar
  created_by uuid [ref: > users.id]
  created_at timestamp [default: now()]
  updated_at timestamp [default: now()]
}

Table transactions {
  id uuid [pk, default: uuid_generate_v4()]
  type transaction_type
  created_by uuid [ref: > users.id, null]
  approved_by uuid [ref: > users.id, null] // If type TRANSFER, null if role OWNER
  from_store_id uuid [ref: > stores.id, null] // If type TRANSFER
  to_store_id uuid [ref: > stores.id, null] // If type TRANSFER
  photo_proof_url text [null]
  transfer_proof_url text [null]
  to varchar
  customer_phone varchar // Client Whatsapp Phone Number 
  amount numeric(12,2) [null]
  is_finished boolean [default: false]
  created_at timestamp [default: now()]
}

Table transaction_items {
  id uuid [pk, default: uuid_generate_v4()]
  transaction_id uuid [ref: > transactions.id]
  product_id uuid [ref: > products.id]
  name varchar
  price numeric(12,2)
  quantity int
  amount numeric(12,2) [null]
  created_at timestamp [default: now()]
}

Table product_checks {
  id uuid [pk, default: uuid_generate_v4()]
  product_id uuid [ref: > products.id]
  checked_by uuid [ref: > users.id]
  store_id uuid [ref: > stores.id]
  status check_status_role
  note text [null]
  checked_at timestamp [default: now()]
}

