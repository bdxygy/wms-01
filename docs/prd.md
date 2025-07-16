## 1. 📦 Warehouse Management Systems

### 2. 🎯 Goals

- Mengoptimalkan pengelolaan barang masuk dan keluar
- Mencegah barang hilang dan kecurian

### 3. 🕒 Durasi Pengembangan

- **1 Bulan**

### 4. 🏪 Target Lokasi

- **Toko dan Gudang**

---

## 5. 👤 Persona / User Stories

### 🧑‍💼 **Owner – Gherkin Scenarios**
@owner
Feature: Owner capabilities

  Background:
    Given I am authenticated as an "OWNER"

  Scenario Outline: Owner CRUD Stores
    When I <operation> a store with valid payload
    Then the store <result>
    And I can see <visibility> the store in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |
      | delete    | is soft-deleted | list only |

  Scenario Outline: Owner CRUD Users
    When I <operation> a <role> user
    Then the user <result>
    And I can see <visibility> the user in the list and detail view
    Examples:
      | operation | role    | result     | visibility |
      | create    | ADMIN   | is created | both       |
      | create    | STAFF   | is created | both       |
      | create    | CASHIER | is created | both       |
      | read      | ADMIN   | is retrieved | both     |
      | update    | STAFF   | is updated | both       |
      | delete    | CASHIER | is soft-deleted | list only |

  Scenario Outline: Owner CRUD Categories
    When I <operation> a category
    Then the category <result>
    And I can see <visibility> the category in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |
      | delete    | is soft-deleted | list only |

  Scenario Outline: Owner CRUD Products
    When I <operation> a product
    Then the product <result>
    And I can see <visibility> the product in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |
      | delete    | is soft-deleted | list only |

  Scenario Outline: Owner CRUD Transactions
    When I <operation> a transaction of type "<type>"
    Then the transaction <result>
    And I can see <visibility> it in the list and detail view
    Examples:
      | operation | type    | result          | visibility |
      | create    | TRANSFER| is created      | both       |
      | create    | SALE    | is created      | both       |
      | read      | SALE    | is retrieved    | both       |
      | update    | TRANSFER| is updated      | both       |
      | delete    | SALE    | is soft-deleted | list only  |

  Scenario: Owner views store analytics
    When I open the analytics dashboard for store "Store-A"
    Then I see in/out items, total revenue and gross profit

  Scenario: Owner views cross-store analytics
    When I open the global analytics dashboard
    Then I see aggregated metrics across all stores

  Scenario: Owner views product check list per store
    When I navigate to the product check page for store "Store-A"
    Then I see two lists: "PENDING" and "OK"

  Scenario: Owner scans barcode to mark as checked
    Given a product exists with barcode "1234567890"
    When I scan barcode "1234567890" in store "Store-A"
    Then the product moves from "PENDING" to "OK"

@admin
Feature: Admin capabilities

  Background:
    Given I am authenticated as an "ADMIN"
    And I work under "Owner-1"
    And I can access all stores owned by "Owner-1" (Store-A, Store-B, Store-C)

  Scenario Outline: Admin CRU Users (only STAFF)
    When I <operation> a "STAFF" user
    Then the user <result>
    And I can see <visibility> the user in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |

  Scenario Outline: Admin CRU Categories
    When I <operation> a category
    Then the category <result>
    And I can see <visibility> the category in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |

  Scenario Outline: Admin CRU Products
    When I <operation> a product
    Then the product <result>
    And I can see <visibility> the product in the list and detail view
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
      | update    | is updated    | both       |

  Scenario Outline: Admin CRU Transactions
    When I <operation> a transaction of type "<type>"
    Then the transaction <result>
    And I can see <visibility> it in the list and detail view
    Examples:
      | operation | type    | result        | visibility |
      | create    | TRANSFER| is created    | both       |
      | create    | SALE    | is created    | both       |
      | read      | SALE    | is retrieved  | both       |
      | update    | TRANSFER| is updated    | both       |

  Scenario: Admin views product check list for any owner store
    When I open the product check page for any store owned by "Owner-1"
    Then I see the "PENDING" and "OK" lists for that store

  Scenario: Admin scans barcode to mark as checked in any owner store
    Given a product exists with barcode "1234567890" in any store owned by "Owner-1"
    When I scan barcode "1234567890" in that store
    Then the product moves from "PENDING" to "OK"

@staff
Feature: Staff capabilities

  Background:
    Given I am authenticated as a "STAFF"
    And I work under "Owner-1"
    And I can access all stores owned by "Owner-1" (Store-A, Store-B, Store-C)

  Scenario: Staff views stores list
    When I open the dashboard page
    Then I see all stores owned by "Owner-1" (Store-A, Store-B, Store-C)

  Scenario: Staff select store from store list
    When I open the Store list page
    Then I can choose any store owned by "Owner-1" (Store-A, Store-B, or Store-C)

  Scenario: Staff views product check list for any owner store
    When I open the product check page for any store owned by "Owner-1"
    Then I see the "PENDING" and "OK" lists for that store

  Scenario: Staff scans barcode to mark as checked in any owner store
    Given a product exists with barcode "1234567890" in any store owned by "Owner-1"
    When I scan barcode "1234567890" in that store
    Then the product moves from "PENDING" to "OK"

@cashier
Feature: Cashier capabilities

  Background:
    Given I am authenticated as a "CASHIER"
    And I work under "Owner-1"
    And I can access all stores owned by "Owner-1" (Store-A, Store-B, Store-C)

  Scenario: Cashier views transaction dashboard
    When I open the dashboard page
    Then I see transaction tab for all stores owned by "Owner-1"

  Scenario: Cashier selects store for transactions
    When I open the transaction dashboard
    Then I can choose any store owned by "Owner-1" to create SALE transactions

  Scenario Outline: Cashier CRU Transactions of type SALE at any owner store
    When I <operation> a transaction of type "SALE" at any store owned by "Owner-1"
    Then the transaction <result>
    And I can see <visibility> it in the list and detail view for that store
    Examples:
      | operation | result        | visibility |
      | create    | is created    | both       |
      | read      | is retrieved  | both       |
---

## 6. 🚀 Key Benefits

- Mempermudah input dan tracking barang di gudang
- Menjamin validitas keluar-masuk barang melalui scan & bukti digital
- Menyediakan analytics yang powerful untuk decision making
- Mencegah kehilangan barang dengan fitur check berkala

---

## 7. 🛠 Tech Stack

### Frontend
React, Shadcn, Zod, React Query, Tailwindcss, Rsbuild

### Backend
Hono, Nodejs, Zod, Prisma, SQLite

---

## 8. Project Features

### 1. Owner

- Bisa membuat dan memiliki banyak toko
- Bisa menambahkan/menghapus Admin, Staff dan Cashier
- Bisa melihat semua analytics dan histori keluar-masuk barang
- Input barang melalui scan barcode
- Output barang as sale dengan scan + upload bukti pembelian
- Output barang as transfer ke toko lain dalam satu owner
- Melihat analytics toko yang dikelola

### 2. Admin

- Input barang melalui scan barcode
- Output barang as sale dengan scan + upload bukti pembelian
- Output barang as transfer ke toko lain dalam satu owner
- Melihat analytics toko yang dikelola

### 3. Staff

- Hanya bisa check barang
- Tidak bisa input barang

### 4. Cashier

- Hanya bisa mengeluarkan barang as sale (scan + foto bukti)

---

## 📦 Jenis Barang

- Handphone (HP)
- Elektronik lainnya

---

## 🔧 Key Functional Requirements

### 🔐 Akses & Roles

- Role-based access control (RBAC) wajib
- Login via email/password
- Web-based system, mobile friendly, tanpa perlu install

---

## 🏪 Struktur Toko

- Owner bisa punya banyak toko
- Satu Owner bisa punya banyak Admin, Staff dan Cashier

---

## 📥 Input Barang

- Hanya bisa dilakukan oleh Owner & Admin
- Wajib scan barcode (bisa via kamera HP langsung)

---

## 📤 Output Barang

- Bisa dilakukan oleh Owner, Admin, dan Cashier
- Wajib scan barcode + upload foto bukti pembelian
- Semua histori tercatat: siapa, kapan, bukti, harga aktual pembelian dll

---

## 📊 Analytics

Laporan lengkap untuk:

- Barang masuk & keluar (kuantitas & harga)
- Periode:

  - Harian
  - Mingguan
  - Bulanan
  - Semesteran
  - Tahunan

- Breakdown per toko

---

## ✅ Halaman Check Barang

- Fitur untuk cek status barang yang sedang stay/digunakan
- Bisa diatur pengecekan berkala (daily, weekly, etc.)
- Tujuan: mencegah kehilangan/pencurian

## ✅ ERD

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
  TRANSFER_IN
  TRANSFER_OUT
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
  email varchar [unique]
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

