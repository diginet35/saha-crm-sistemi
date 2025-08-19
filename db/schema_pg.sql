-- Temiz başla
DROP TABLE IF EXISTS invoice_items CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS delivery_note_items CASCADE;
DROP TABLE IF EXISTS delivery_notes CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS account_movements CASCADE;
DROP TABLE IF EXISTS account_transactions CASCADE;
DROP TABLE IF EXISTS visits CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- Yardımcı tablolar
CREATE TABLE roles (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE departments (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

-- Kullanıcılar
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  email TEXT,
  full_name TEXT,
  phone TEXT,
  password_hash TEXT NOT NULL,
  role_id BIGINT REFERENCES roles(id),
  department_id BIGINT REFERENCES departments(id),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Müşteriler
CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  company_name TEXT NOT NULL,
  contact_person TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  notes TEXT,
  assigned_sales_rep BIGINT REFERENCES users(id),
  customer_status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_customers_company ON customers(company_name);

-- Ürünler
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  unit TEXT,
  unit_price NUMERIC(12,2) NOT NULL DEFAULT 0,
  vat_rate NUMERIC(5,2) NOT NULL DEFAULT 0,
  price_with_vat NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Sipariş başlık
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  order_number TEXT UNIQUE,
  customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
  sales_rep_id BIGINT REFERENCES users(id),
  order_date DATE NOT NULL DEFAULT CURRENT_DATE,
  delivery_date DATE,
  payment_due_date DATE,
  total_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Sipariş kalemleri
CREATE TABLE order_items (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(id),
  quantity NUMERIC(14,3) NOT NULL DEFAULT 0,
  unit_price NUMERIC(14,2) NOT NULL DEFAULT 0,
  total_price NUMERIC(14,2) NOT NULL DEFAULT 0,
  unit TEXT
);
CREATE INDEX idx_order_items_order ON order_items(order_id);

-- İrsaliyeler
CREATE TABLE delivery_notes (
  id BIGSERIAL PRIMARY KEY,
  delivery_note_number TEXT UNIQUE,
  order_id BIGINT REFERENCES orders(id) ON DELETE SET NULL,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  delivery_date DATE,
  total_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
  notes TEXT,
  created_by BIGINT REFERENCES users(id),
  signature_data TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE delivery_note_items (
  id BIGSERIAL PRIMARY KEY,
  delivery_note_id BIGINT NOT NULL REFERENCES delivery_notes(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(id),
  unit TEXT,
  quantity NUMERIC(14,3) NOT NULL DEFAULT 0,
  unit_price NUMERIC(14,2) NOT NULL DEFAULT 0,
  total_price NUMERIC(14,2) NOT NULL DEFAULT 0
);

-- Faturalar
CREATE TABLE invoices (
  id BIGSERIAL PRIMARY KEY,
  invoice_number TEXT UNIQUE,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
  total_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
  remaining_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
  created_by BIGINT REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE invoice_items (
  id BIGSERIAL PRIMARY KEY,
  invoice_id BIGINT NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(id),
  unit TEXT,
  quantity NUMERIC(14,3) NOT NULL DEFAULT 0,
  unit_price NUMERIC(14,2) NOT NULL DEFAULT 0,
  total_price NUMERIC(14,2) NOT NULL DEFAULT 0
);

-- Tahsilat/Ödemeler
CREATE TABLE payments (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  invoice_id BIGINT REFERENCES invoices(id) ON DELETE SET NULL,
  cash_register_id BIGINT,
  payment_method TEXT,           -- nakit/kart/havale vb.
  amount NUMERIC(14,2) NOT NULL DEFAULT 0,
  payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
  reference_number TEXT,
  notes TEXT,
  created_by BIGINT REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Cari hareket özetleri
CREATE TABLE account_transactions (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
  transaction_type TEXT,         -- debit/credit vb.
  amount NUMERIC(14,2) NOT NULL DEFAULT 0,
  description TEXT,
  created_by BIGINT REFERENCES users(id),
  reference_number TEXT
);

-- Cari hareket detayları
CREATE TABLE account_movements (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  movement_date DATE NOT NULL DEFAULT CURRENT_DATE,
  movement_type TEXT,            -- order/invoice/payment vb.
  reference_id BIGINT,
  reference_number TEXT,
  debit_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
  credit_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
  description TEXT
);

-- Ziyaretler
CREATE TABLE visits (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  sales_rep_id BIGINT REFERENCES users(id),
  visit_date DATE NOT NULL DEFAULT CURRENT_DATE,
  visit_type TEXT,                      -- telefon/yüz yüze vb.
  interested_products TEXT,
  estimated_order_amount NUMERIC(14,2),
  result TEXT,
  next_contact_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
