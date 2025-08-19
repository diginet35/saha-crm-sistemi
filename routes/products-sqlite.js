const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const router = express.Router();

const dbPath = path.join(__dirname, '..', 'database', 'saha_crm.db');
const db = new sqlite3.Database(dbPath);

// Tüm ürünleri listele
router.get('/', (req, res) => {
  db.all('SELECT * FROM products ORDER BY created_at DESC', (err, products) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(products);
  });
});

// Yeni ürün ekle
router.post('/', (req, res) => {
  const { name, description, unit_price, vat_rate, price_with_vat, unit } = req.body;
  
  db.run(
    'INSERT INTO products (name, description, unit_price, vat_rate, price_with_vat, unit) VALUES (?, ?, ?, ?, ?, ?)',
    [name, description, unit_price, vat_rate || 20, price_with_vat, unit || 'adet'],
    function(err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ id: this.lastID, message: 'Ürün oluşturuldu' });
    }
  );
});

// Ürün güncelle
router.put('/:id', (req, res) => {
  const { name, description, unit_price, vat_rate, price_with_vat, unit, is_active } = req.body;
  
  db.run(
    'UPDATE products SET name = ?, description = ?, unit_price = ?, vat_rate = ?, price_with_vat = ?, unit = ?, is_active = ? WHERE id = ?',
    [name, description, unit_price, vat_rate, price_with_vat, unit, is_active, req.params.id],
    function(err) {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ message: 'Ürün güncellendi' });
    }
  );
});

module.exports = router;