import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:uuid/uuid.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  Database? _db;
  final _uuid = const Uuid();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    DatabaseFactory dbFactory;
    String dbPath;

    if (kIsWeb) {
      dbFactory = databaseFactoryFfiWeb;
      dbPath = 'tailor_pro.db';
    } else {
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        sqfliteFfiInit();
        dbFactory = databaseFactoryFfi;
      } else {
        dbFactory = databaseFactory;
      }
      final databasesPath = await dbFactory.getDatabasesPath();
      dbPath = p.join(databasesPath, 'tailor_pro.db');
    }

    return await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Businesses
    await db.execute('''
      CREATE TABLE businesses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        tagline TEXT,
        logo_path TEXT,
        owner_name TEXT NOT NULL,
        phone_primary TEXT NOT NULL,
        phone_secondary TEXT,
        address TEXT,
        currency_symbol TEXT DEFAULT 'Rs.',
        ntn_tax_id TEXT,
        invoice_footer_text TEXT,
        pin_hash TEXT,
        is_biometric_enabled INTEGER DEFAULT 0,
        serial_prefix TEXT DEFAULT '',
        serial_start_number INTEGER DEFAULT 1,
        current_serial_number INTEGER DEFAULT 1,
        default_unit TEXT DEFAULT 'inch',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    // 2. Staff
    await db.execute('''
      CREATE TABLE staff (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL,
        pin_hash TEXT,
        rate_per_suit REAL DEFAULT 0.0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    // 3. Customers
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        serial_no INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        secondary_phone TEXT,
        address TEXT,
        photo_path TEXT,
        notes TEXT,
        current_balance REAL DEFAULT 0.0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');
    await db.execute('CREATE INDEX idx_customers_search ON customers(business_id, serial_no, phone, name)');

    // 4. Custom Options (Persisted (+) custom additions per shop)
    await db.execute('''
      CREATE TABLE custom_options (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        category TEXT NOT NULL,
        value_en TEXT NOT NULL,
        value_ur TEXT NOT NULL,
        is_enabled INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    // 5. Garment Templates
    await db.execute('''
      CREATE TABLE garment_templates (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        name_en TEXT NOT NULL,
        name_ur TEXT NOT NULL,
        garment_type TEXT NOT NULL,
        default_fields_json TEXT NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // 6. Customer Measurements
    await db.execute('''
      CREATE TABLE customer_measurements (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        business_id TEXT NOT NULL,
        garment_template_id TEXT NOT NULL,
        version_number INTEGER DEFAULT 1,
        unit TEXT DEFAULT 'inch',
        measurements_json TEXT NOT NULL,
        style_options_json TEXT,
        extra_details_text TEXT,
        audio_note_path TEXT,
        sketch_svg_path TEXT,
        recorded_by_staff_id TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_measurements_cust ON customer_measurements(customer_id, created_at DESC)');

    // 7. Orders
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        customer_id TEXT NOT NULL,
        order_number TEXT NOT NULL,
        measurement_id TEXT NOT NULL,
        garment_type TEXT NOT NULL,
        quantity INTEGER DEFAULT 1,
        fabric_source TEXT NOT NULL,
        fabric_notes TEXT,
        fabric_photo_path TEXT,
        design_photo_path TEXT,
        is_urgent INTEGER DEFAULT 0,
        urgent_surcharge REAL DEFAULT 0.0,
        total_stitching_charges REAL NOT NULL,
        total_fabric_charges REAL DEFAULT 0.0,
        other_charges REAL DEFAULT 0.0,
        discount_amount REAL DEFAULT 0.0,
        grand_total REAL NOT NULL,
        advance_paid REAL DEFAULT 0.0,
        balance_due REAL NOT NULL,
        status TEXT NOT NULL,
        assigned_cutter_id TEXT,
        assigned_tailor_id TEXT,
        cutter_wage REAL DEFAULT 0.0,
        tailor_wage REAL DEFAULT 0.0,
        order_date INTEGER NOT NULL,
        trial_date INTEGER,
        delivery_date INTEGER NOT NULL,
        delivered_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');
    await db.execute('CREATE INDEX idx_orders_status ON orders(business_id, status, delivery_date)');

    // 8. Invoices
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        order_id TEXT NOT NULL,
        customer_id TEXT NOT NULL,
        invoice_number TEXT NOT NULL UNIQUE,
        subtotal REAL NOT NULL,
        tax_amount REAL DEFAULT 0.0,
        discount_amount REAL DEFAULT 0.0,
        grand_total REAL NOT NULL,
        paid_amount REAL NOT NULL,
        balance_amount REAL NOT NULL,
        payment_status TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // 9. Payments
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        customer_id TEXT NOT NULL,
        order_id TEXT,
        invoice_id TEXT,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        reference_no TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // 10. Customer Ledger
    await db.execute('''
      CREATE TABLE customer_ledger (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        customer_id TEXT NOT NULL,
        order_id TEXT,
        payment_id TEXT,
        entry_type TEXT NOT NULL,
        amount REAL NOT NULL,
        balance_after REAL NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // 11. Expenses
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT DEFAULT 'cash',
        recipient_name TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // 12. Inventory
    await db.execute('''
      CREATE TABLE inventory_items (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        cost_price REAL DEFAULT 0.0,
        low_stock_threshold REAL DEFAULT 5.0,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  /// Initialize default business templates and default style options for a newly created business
  Future<void> seedDefaultBusinessData(String businessId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Default Garment Templates
    final templates = [
      {
        'id': _uuid.v4(),
        'business_id': businessId,
        'name_en': 'Shalwar Kameez',
        'name_ur': 'شلوار قمیض',
        'garment_type': 'shalwar_kameez',
        'default_fields_json': jsonEncode([
          {'key': 'length', 'label_en': 'Kameez Length', 'label_ur': 'لمبائی قمیض'},
          {'key': 'chest', 'label_en': 'Chest', 'label_ur': 'چھاتی'},
          {'key': 'waist', 'label_en': 'Waist', 'label_ur': 'کمر'},
          {'key': 'hip', 'label_en': 'Hip', 'label_ur': 'ہپ'},
          {'key': 'shoulder_teera', 'label_en': 'Shoulder / Teera', 'label_ur': 'تیرا (شولڈر)'},
          {'key': 'sleeve_arm', 'label_en': 'Sleeve / Arm', 'label_ur': 'بازو (آستین)'},
          {'key': 'collar_neck', 'label_en': 'Collar / Neck', 'label_ur': 'گلا / کالر'},
          {'key': 'ghera', 'label_en': 'Ghera / Daman', 'label_ur': 'گھیرا / دامن'},
          {'key': 'shalwar_length', 'label_en': 'Shalwar Length', 'label_ur': 'لمبائی شلوار'},
          {'key': 'paincha', 'label_en': 'Paincha / Bottom', 'label_ur': 'پائنچہ'},
          {'key': 'asan', 'label_en': 'Asan / Crotch', 'label_ur': 'آسن'},
          {'key': 'thigh_ran', 'label_en': 'Thigh', 'label_ur': 'ران'},
        ]),
        'is_active': 1,
      },
      {
        'id': _uuid.v4(),
        'business_id': businessId,
        'name_en': 'Kurta',
        'name_ur': 'کرتا',
        'garment_type': 'kurta',
        'default_fields_json': jsonEncode([
          {'key': 'length', 'label_en': 'Kurta Length', 'label_ur': 'لمبائی کرتا'},
          {'key': 'chest', 'label_en': 'Chest', 'label_ur': 'چھاتی'},
          {'key': 'shoulder_teera', 'label_en': 'Shoulder / Teera', 'label_ur': 'تیرا'},
          {'key': 'sleeve_arm', 'label_en': 'Sleeve', 'label_ur': 'بازو'},
          {'key': 'collar_neck', 'label_en': 'Collar / Ban', 'label_ur': 'بین / گلا'},
          {'key': 'ghera', 'label_en': 'Ghera', 'label_ur': 'گھیرا'},
          {'key': 'shalwar_length', 'label_en': 'Trouser / Shalwar', 'label_ur': 'شلوار / پاجامہ'},
          {'key': 'paincha', 'label_en': 'Paincha', 'label_ur': 'پائنچہ'},
        ]),
        'is_active': 1,
      },
      {
        'id': _uuid.v4(),
        'business_id': businessId,
        'name_en': 'Waistcoat',
        'name_ur': 'ویسٹ کوٹ',
        'garment_type': 'waistcoat',
        'default_fields_json': jsonEncode([
          {'key': 'waistcoat_length', 'label_en': 'Length', 'label_ur': 'لمبائی ویسٹ کوٹ'},
          {'key': 'chest', 'label_en': 'Chest', 'label_ur': 'چھاتی'},
          {'key': 'waist', 'label_en': 'Waist', 'label_ur': 'کمر'},
          {'key': 'shoulder_teera', 'label_en': 'Shoulder', 'label_ur': 'تیرا'},
          {'key': 'collar_neck', 'label_en': 'Neck / Ban', 'label_ur': 'بین'},
          {'key': 'armhole', 'label_en': 'Armhole', 'label_ur': 'موڈھا'},
        ]),
        'is_active': 1,
      },
      {
        'id': _uuid.v4(),
        'business_id': businessId,
        'name_en': 'Pant & Shirt',
        'name_ur': 'پینٹ شرٹ',
        'garment_type': 'pant_shirt',
        'default_fields_json': jsonEncode([
          {'key': 'shirt_length', 'label_en': 'Shirt Length', 'label_ur': 'شرٹ لمبائی'},
          {'key': 'chest', 'label_en': 'Chest', 'label_ur': 'چھاتی'},
          {'key': 'shoulder_teera', 'label_en': 'Shoulder', 'label_ur': 'تیرا'},
          {'key': 'sleeve_arm', 'label_en': 'Sleeve', 'label_ur': 'بازو'},
          {'key': 'collar_neck', 'label_en': 'Collar', 'label_ur': 'کالر'},
          {'key': 'pant_length', 'label_en': 'Pant Length', 'label_ur': 'پینٹ لمبائی'},
          {'key': 'pant_waist', 'label_en': 'Pant Waist', 'label_ur': 'پینٹ کمر'},
          {'key': 'hip', 'label_en': 'Hip', 'label_ur': 'ہپ'},
          {'key': 'thigh_ran', 'label_en': 'Thigh', 'label_ur': 'ران'},
          {'key': 'knee', 'label_en': 'Knee', 'label_ur': 'گھٹنا'},
          {'key': 'trouser_bottom', 'label_en': 'Bottom', 'label_ur': 'باٹم'},
        ]),
        'is_active': 1,
      },
      {
        'id': _uuid.v4(),
        'business_id': businessId,
        'name_en': 'Suit / Coat',
        'name_ur': 'کوٹ سوٹ',
        'garment_type': 'coat_suit',
        'default_fields_json': jsonEncode([
          {'key': 'coat_length', 'label_en': 'Coat Length', 'label_ur': 'کوٹ لمبائی'},
          {'key': 'chest', 'label_en': 'Chest', 'label_ur': 'چھاتی'},
          {'key': 'waist', 'label_en': 'Waist', 'label_ur': 'کمر'},
          {'key': 'cross_back', 'label_en': 'Cross Back', 'label_ur': 'کراس بیک'},
          {'key': 'shoulder_teera', 'label_en': 'Shoulder', 'label_ur': 'تیرا'},
          {'key': 'sleeve_arm', 'label_en': 'Sleeve', 'label_ur': 'بازو'},
          {'key': 'trouser_length', 'label_en': 'Trouser Length', 'label_ur': 'ٹراؤزر لمبائی'},
          {'key': 'trouser_waist', 'label_en': 'Trouser Waist', 'label_ur': 'ٹراؤزر کمر'},
          {'key': 'trouser_bottom', 'label_en': 'Trouser Bottom', 'label_ur': 'ٹراؤزر باٹم'},
        ]),
        'is_active': 1,
      },
    ];

    for (final t in templates) {
      await db.insert('garment_templates', t, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Default Style Options Preset Seed
    final defaultStyles = [
      {'cat': 'collar_band', 'en': 'Full Mandarin Band', 'ur': 'مکمل بین (فل بین)'},
      {'cat': 'collar_band', 'en': 'Half Band', 'ur': 'ہاف بین'},
      {'cat': 'collar_band', 'en': 'Shirt Collar', 'ur': 'شرٹ کالر'},
      {'cat': 'collar_band', 'en': 'Cut Band', 'ur': 'کٹ بین'},
      {'cat': 'front_patti', 'en': 'Hidden Button Placket', 'ur': 'گم پٹی'},
      {'cat': 'front_patti', 'en': 'Standard Button Placket', 'ur': 'سامنے کاج پٹی'},
      {'cat': 'front_patti', 'en': 'Kurta Placket', 'ur': 'سادہ کرتا پٹی'},
      {'cat': 'cuff_style', 'en': 'Single Cuff', 'ur': 'سنگل کف'},
      {'cat': 'cuff_style', 'en': 'Double Cuff', 'ur': 'ڈبل کف'},
      {'cat': 'cuff_style', 'en': 'Round Cuff', 'ur': 'گول کف'},
      {'cat': 'cuff_style', 'en': 'Open Sleeve', 'ur': 'کھلا بازو (سادہ)'},
      {'cat': 'pocket_style', 'en': '1 Front Pocket', 'ur': '1 سامنے جیب'},
      {'cat': 'pocket_style', 'en': '2 Front Pockets', 'ur': '2 سامنے جیبیں'},
      {'cat': 'pocket_style', 'en': 'No Front Pocket', 'ur': 'بغیر سامنے جیب'},
      {'cat': 'side_pocket', 'en': '1 Side Pocket', 'ur': '1 سائیڈ جیب'},
      {'cat': 'side_pocket', 'en': '2 Side Pockets', 'ur': '2 سائیڈ جیبیں'},
      {'cat': 'daman_style', 'en': 'Round Daman', 'ur': 'گول دامن'},
      {'cat': 'daman_style', 'en': 'Square Daman', 'ur': 'چورس دامن (سیدھا)'},
    ];

    for (final s in defaultStyles) {
      await db.insert('custom_options', {
        'id': _uuid.v4(),
        'business_id': businessId,
        'category': s['cat']!,
        'value_en': s['en']!,
        'value_ur': s['ur']!,
        'is_enabled': 1,
        'created_at': now,
      });
    }
  }

  /// Add custom option dynamically with (+) button.
  /// Automatically persists for future use as requested by the user.
  Future<void> addCustomOption({
    required String businessId,
    required String category,
    required String valueEn,
    required String valueUr,
  }) async {
    final db = await database;
    await db.insert('custom_options', {
      'id': _uuid.v4(),
      'business_id': businessId,
      'category': category,
      'value_en': valueEn,
      'value_ur': valueUr,
      'is_enabled': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Fetch active style options for a business category
  Future<List<Map<String, dynamic>>> getCustomOptions(String businessId, String category) async {
    final db = await database;
    return await db.query(
      'custom_options',
      where: 'business_id = ? AND category = ? AND is_enabled = 1',
      whereArgs: [businessId, category],
      orderBy: 'created_at ASC',
    );
  }
}

