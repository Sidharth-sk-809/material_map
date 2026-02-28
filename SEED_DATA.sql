-- Material Map - Complete Demo Data for Supabase
-- Copy and paste this entire script into Supabase SQL Editor and run once

-- ============ STORES DATA ============

INSERT INTO stores (id, name, category, address, latitude, longitude, phone, image_url, created_at) VALUES
-- GROCERY STORES
('store-001', '🥬 Fresh Vegetables', 'grocery', 'Green Market, Main Street, Downtown', 11.3415, 77.7171, '+91-123-456-7890', NULL, NOW()),
('store-002', '🆕 New Veggies Market', 'grocery', 'Modern Plaza, Park Road, Uptown', 11.3380, 77.7250, '+91-123-456-7891', NULL, NOW()),
('store-003', '🌾 Organic Grains Hub', 'grocery', 'Farmer''s Market, NH-47, Bypass', 11.3500, 77.7100, '+91-123-456-7892', NULL, NOW()),
('store-004', '🛢️ Premium Foods Store', 'grocery', 'Premium Plaza, Business District', 11.3450, 77.7300, '+91-123-456-7893', NULL, NOW()),

-- STATIONERY STORES
('store-005', '📚 Manus Store', 'stationery', 'Education Plaza, School Road', 11.3425, 77.7180, '+91-234-567-8901', NULL, NOW()),
('store-006', '✏️ Scholar''s Hub', 'stationery', 'Study Center, College Avenue', 11.3405, 77.7210, '+91-234-567-8902', NULL, NOW()),
('store-007', '📖 Knowledge Corner', 'stationery', 'Library Lane, Community Center', 11.3435, 77.7160, '+91-234-567-8903', NULL, NOW()),

-- HOUSEHOLD STORES
('store-008', '🧹 Clean Home Mart', 'household', 'Shopping Complex, Market Street', 11.3410, 77.7190, '+91-345-678-9012', NULL, NOW()),
('store-009', '🏠 Home Essentials', 'household', 'Retail Park, Trade Avenue', 11.3420, 77.7140, '+91-345-678-9013', NULL, NOW()),

-- PLUMBING STORES
('store-010', '🔧 Pipe & Valve Hub', 'plumbing', 'Industrial Area, Engineering Road', 11.3450, 77.7210, '+91-456-789-0123', NULL, NOW()),
('store-011', '💧 Plumbing Plus', 'plumbing', 'Trade Center, Commerce Lane', 11.3380, 77.7160, '+91-456-789-0124', NULL, NOW()),

-- ELECTRONICS STORES
('store-012', '💡 Electronics World', 'electronics', 'Tech Park, Digital Avenue', 11.3390, 77.7230, '+91-567-890-1234', NULL, NOW()),
('store-013', '⚡ Power & Lights', 'electronics', 'Shopping Hub, Retail Drive', 11.3430, 77.7120, '+91-567-890-1235', NULL, NOW());

-- ============ PRODUCTS DATA ============

INSERT INTO products (id, name, brand, category, unit, description, image_url, created_at) VALUES
-- GROCERY PRODUCTS
('prod-001', 'Basmati Rice', 'India Gate', 'grocery', '1 kg', 'Premium basmati | Mfg: Jan 2026 | Best Before: Dec 2027', NULL, NOW()),
('prod-002', 'Jasmine Rice', 'Tata', 'grocery', '1 kg', 'Jasmine fragrant | Mfg: Feb 2026 | Best Before: Jan 2028', NULL, NOW()),
('prod-003', 'Cooking Oil', 'Fortune', 'grocery', '1 L', 'Pure vegetable | Mfg: Mar 2026 | Best Before: Mar 2027', NULL, NOW()),
('prod-004', 'Olive Oil', 'Figaro', 'grocery', '500 ml', 'Extra virgin | Mfg: Dec 2025 | Best Before: Dec 2026', NULL, NOW()),
('prod-005', 'Whole Wheat Atta', 'Aashirvaad', 'grocery', '5 kg', 'Stone ground | Mfg: Feb 2026 | Best Before: Aug 2026', NULL, NOW()),
('prod-006', 'Toor Dal', 'Tata Sampann', 'grocery', '500 g', 'Yellow split | Mfg: Jan 2026 | Best Before: Jan 2027', NULL, NOW()),
('prod-007', 'Sugar', 'Uttam', 'grocery', '1 kg', 'Refined | Mfg: Feb 2026 | Best Before: Feb 2027', NULL, NOW()),
('prod-008', 'Salt', 'Tata Salt', 'grocery', '1 kg', 'Iodized | Mfg: Jan 2026 | Best Before: Dec 2026', NULL, NOW()),

-- VEGETABLES
('prod-009', 'Tomato', 'Local Fresh', 'vegetables', '500 g', 'Red ripe tomatoes | Fresh arrival | Best within 3 days', NULL, NOW()),
('prod-010', 'Potato', 'Organic Picks', 'vegetables', '1 kg', 'White potato | Mfg: Feb 2026', NULL, NOW()),
('prod-011', 'Onion', 'Farm Fresh', 'vegetables', '1 kg', 'Golden onion | Fresh stock | Best within 2 weeks', NULL, NOW()),
('prod-012', 'Carrot', 'Fresh Farm', 'vegetables', '500 g', 'Orange carrots | Mfg: Feb 2026 | Best: 1 week', NULL, NOW()),
('prod-013', 'Broccoli', 'Green Picks', 'vegetables', '1 head', 'Fresh green broccoli | Best consumed within 5 days', NULL, NOW()),
('prod-014', 'Capsicum', 'Agro Fresh', 'vegetables', '250 g', 'Mixed colors | Fresh | Best within 1 week', NULL, NOW()),

-- STATIONERY
('prod-015', 'Notebook 100p', 'Classmate', 'stationery', '100 pages', 'Ruled | Mfg: Jan 2026', NULL, NOW()),
('prod-016', 'Notebook 200p', 'Classmate', 'stationery', '200 pages', 'Ruled | Mfg: Jan 2026', NULL, NOW()),
('prod-017', 'Drawing Book', 'Camlin', 'stationery', '150 pages', 'Blank | Mfg: Feb 2026', NULL, NOW()),
('prod-018', 'Pens 5pack', 'Reynolds', 'stationery', 'Pack of 5', 'Blue ballpoint | Mfg: Dec 2025', NULL, NOW()),
('prod-019', 'Pens 10pack', 'Reynolds', 'stationery', 'Pack of 10', 'Blue ballpoint | Mfg: Dec 2025', NULL, NOW()),
('prod-020', 'Pencils 12set', 'Camlin', 'stationery', 'Set of 12', 'HB lead | Mfg: Jan 2026', NULL, NOW()),
('prod-021', 'Pencils 24set', 'Camlin', 'stationery', 'Set of 24', 'Assorted | Mfg: Jan 2026', NULL, NOW()),
('prod-022', 'Stapler', 'Kangaro', 'stationery', '1 piece', 'Desktop stapler | Mfg: Nov 2025', NULL, NOW()),
('prod-023', 'Eraser 2pack', 'Apsara', 'stationery', 'Pack of 2', 'Vinyl eraser | Mfg: Dec 2025', NULL, NOW()),
('prod-024', 'Ruler 30cm', 'Camlin', 'stationery', '30 cm', 'Plastic ruler | Mfg: Jan 2026', NULL, NOW()),

-- HOUSEHOLD
('prod-025', 'Detergent', 'Surf Excel', 'household', '1 kg', 'Powder detergent | Mfg: Feb 2026 | Best Before: Feb 2027', NULL, NOW()),
('prod-026', 'Dish Soap', 'Vim', 'household', '750 ml', 'Liquid soap | Mfg: Mar 2026 | Best Before: Mar 2027', NULL, NOW()),
('prod-027', 'Paper Towels', 'Scotch Brite', 'household', '2 rolls', '2-ply roll | Mfg: Jan 2026 | Best Before: Jan 2028', NULL, NOW()),
('prod-028', 'Trash Bags', 'Safewrap', 'household', 'Pack of 30', 'Large size bags | Mfg: Feb 2026 | Best Before: Feb 2028', NULL, NOW()),

-- PLUMBING
('prod-029', 'Chrome Faucet', 'Parryware', 'plumbing', '1 piece', 'Modern chrome finish | Hot & cold water | Mfg: Jan 2026', NULL, NOW()),
('prod-030', 'Adjustable Wrench', 'Stanley', 'plumbing', '10 inch', 'Professional grade | Mfg: Dec 2025 | Best for 8-30mm', NULL, NOW()),
('prod-031', 'PVC Pipe', 'Supreme', 'plumbing', '3 m length', 'Water delivery | Class B | Mfg: Feb 2026 | Durable', NULL, NOW()),
('prod-032', 'Teflon Tape', 'Tapex', 'plumbing', 'Pack of 3', 'Thread seal tape | Mfg: Jan 2026 | Standard width', NULL, NOW()),

-- ELECTRONICS
('prod-033', 'LED Bulb 9W', 'Philips', 'electronics', '1 piece', 'Warm white | 6500K | Mfg: Feb 2026 | Energy efficient', NULL, NOW()),
('prod-034', 'Extension Cord', 'Anchor', 'electronics', '5 m', 'Heavy duty | 3 pins | Mfg: Jan 2026 | Safety certified', NULL, NOW()),
('prod-035', 'USB-C Charger', 'Boat', 'electronics', '20W', 'Fast charging | Mfg: Mar 2026 | Universal compatible', NULL, NOW()),
('prod-036', 'AA Batteries', 'Duracell', 'electronics', 'Pack of 4', 'Alkaline | Ultra power | Mfg: Feb 2026 | Long lasting', NULL, NOW());

-- ============ INVENTORY DATA ============

-- Grocery inventory
INSERT INTO inventory_item (id, product_id, store_id, price, quantity, original_price, discount_percentage, offer_valid_until, updated_at) VALUES
('inv-001', 'prod-001', 'store-001', 95.00, 45, 95.00, 0, NULL, NOW()),
('inv-002', 'prod-001', 'store-002', 100.00, 52, 100.00, 0, NULL, NOW()),
('inv-003', 'prod-001', 'store-003', 93.50, 38, 110.00, 15, NOW()::timestamp + interval '30 days', NOW()),
('inv-004', 'prod-001', 'store-004', 92.00, 60, 92.00, 0, NULL, NOW()),

('inv-005', 'prod-002', 'store-001', 105.00, 40, 105.00, 0, NULL, NOW()),
('inv-006', 'prod-002', 'store-002', 110.00, 48, 110.00, 0, NULL, NOW()),
('inv-007', 'prod-002', 'store-003', 103.50, 35, 115.00, 15, NOW()::timestamp + interval '30 days', NOW()),
('inv-008', 'prod-002', 'store-004', 102.00, 58, 102.00, 0, NULL, NOW()),

-- Vegetables inventory
('inv-101', 'prod-009', 'store-001', 35.00, 25, 35.00, 0, NULL, NOW()),
('inv-102', 'prod-009', 'store-002', 30.40, 18, 38.00, 20, NOW()::timestamp + interval '30 days', NOW()),
('inv-103', 'prod-009', 'store-003', 32.00, 32, 32.00, 0, NULL, NOW()),
('inv-104', 'prod-009', 'store-004', 32.00, 22, 40.00, 20, NOW()::timestamp + interval '30 days', NOW()),

('inv-105', 'prod-010', 'store-001', 35.00, 30, 35.00, 0, NULL, NOW()),
('inv-106', 'prod-010', 'store-002', 30.40, 20, 38.00, 20, NOW()::timestamp + interval '30 days', NOW()),
('inv-107', 'prod-010', 'store-003', 32.00, 28, 32.00, 0, NULL, NOW()),
('inv-108', 'prod-010', 'store-004', 36.00, 25, 40.00, 20, NOW()::timestamp + interval '30 days', NOW()),

-- Stationery inventory
('inv-201', 'prod-015', 'store-005', 76.50, 150, 85.00, 10, NOW()::timestamp + interval '30 days', NOW()),
('inv-202', 'prod-015', 'store-006', 92.00, 120, 92.00, 0, NULL, NOW()),
('inv-203', 'prod-015', 'store-007', 78.00, 180, 78.00, 0, NULL, NOW()),

('inv-204', 'prod-016', 'store-005', 82.80, 140, 92.00, 10, NOW()::timestamp + interval '30 days', NOW()),
('inv-205', 'prod-016', 'store-006', 100.00, 110, 100.00, 0, NULL, NOW()),
('inv-206', 'prod-016', 'store-007', 85.00, 170, 85.00, 0, NULL, NOW()),

-- Household inventory
('inv-301', 'prod-025', 'store-008', 120.00, 75, 120.00, 0, NULL, NOW()),
('inv-302', 'prod-025', 'store-009', 110.00, 85, 125.00, 12, NOW()::timestamp + interval '30 days', NOW()),

('inv-303', 'prod-026', 'store-008', 125.00, 60, 125.00, 0, NULL, NOW()),
('inv-304', 'prod-026', 'store-009', 110.00, 70, 125.00, 12, NOW()::timestamp + interval '30 days', NOW()),

-- Plumbing inventory
('inv-401', 'prod-029', 'store-010', 414.00, 45, 450.00, 8, NOW()::timestamp + interval '30 days', NOW()),
('inv-402', 'prod-029', 'store-011', 480.00, 50, 480.00, 0, NULL, NOW()),

('inv-403', 'prod-030', 'store-010', 459.00, 45, 495.00, 8, NOW()::timestamp + interval '30 days', NOW()),
('inv-404', 'prod-030', 'store-011', 495.00, 50, 495.00, 0, NULL, NOW()),

-- Electronics inventory
('inv-501', 'prod-033', 'store-012', 550.00, 60, 550.00, 0, NULL, NOW()),
('inv-502', 'prod-033', 'store-013', 492.00, 70, 600.00, 18, NOW()::timestamp + interval '30 days', NOW()),

('inv-503', 'prod-034', 'store-012', 560.00, 50, 560.00, 0, NULL, NOW()),
('inv-504', 'prod-034', 'store-013', 492.80, 65, 600.00, 18, NOW()::timestamp + interval '30 days', NOW()),

('inv-505', 'prod-035', 'store-012', 470.00, 40, 470.00, 0, NULL, NOW()),
('inv-506', 'prod-035', 'store-013', 410.00, 58, 500.00, 18, NOW()::timestamp + interval '30 days', NOW()),

('inv-507', 'prod-036', 'store-012', 200.00, 80, 200.00, 0, NULL, NOW()),
('inv-508', 'prod-036', 'store-013', 164.00, 90, 200.00, 18, NOW()::timestamp + interval '30 days', NOW());

-- ============ VERIFICATION ============
-- Verify data was inserted
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Stores', COUNT(*) FROM stores
UNION ALL
SELECT 'Inventory', COUNT(*) FROM inventory_item;
