import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'travel_app.db';
  static const int _dbVersion = 1;

  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        phone TEXT,
        profile_image TEXT,
        current_latitude REAL,
        current_longitude REAL,
        current_address TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Destinations table (cache API data)
    await db.execute('''
      CREATE TABLE destinations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        api_id TEXT UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        location TEXT,
        latitude REAL,
        longitude REAL,
        price REAL,
        rating REAL,
        image_url TEXT,
        category TEXT,
        is_popular INTEGER DEFAULT 0,
        distance_from_user REAL,
        cached_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // User locations history (GPS tracking)
    await db.execute('''
      CREATE TABLE user_locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT,
        accuracy REAL,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Bookmarks table
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        destination_id INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (destination_id) REFERENCES destinations (id)
      )
    ''');

    // Tickets table (local storage + API sync)
    await db.execute('''
      CREATE TABLE tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        api_id TEXT UNIQUE,
        user_id INTEGER,
        destination_id INTEGER,
        ticket_number TEXT UNIQUE,
        destination_name TEXT,
        destination_image TEXT,
        trip_date TEXT,
        trip_time TEXT,
        participants INTEGER,
        status TEXT,
        trip_type TEXT,
        base_price REAL,
        total_price REAL,
        includes_transportation INTEGER DEFAULT 0,
        includes_accommodation INTEGER DEFAULT 0,
        includes_meals INTEGER DEFAULT 0,
        user_email TEXT,
        user_name TEXT,
        user_phone TEXT,
        special_requests TEXT,
        booked_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced_to_api INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Insert default user
    await db.insert('users', {
      'id': 1,
      'name': 'Citra Anggrika',
      'email': 'citra.anggrika@email.com',
      'phone': '+6281234567890',
    });

    // Insert sample destinations with location data (Bali coordinates)
    await db.rawInsert('''
      INSERT OR IGNORE INTO destinations (
        name, description, location, latitude, longitude, price, rating, 
        image_url, category, is_popular
      ) VALUES 
        ('Gunung Agung', 'Gunung Agung adalah gunung berapi tertinggi di Pulau Bali, Indonesia, dengan ketinggian sekitar 3.031 meter di atas permukaan laut (mdpl). Terletak di Kabupaten Karangasem, gunung ini merupakan salah satu tempat paling sakral bagi masyarakat Bali.', 'Karangasem, Bali', -8.3436, 115.5068, 500000, 4.8, 'assets/gunung_agung.jpg', 'Gunung', 1),
        ('Lempuyang', 'Pura Lempuyang adalah sebuah pura Hindu yang terletak di lereng Gunung Lempuyang, Karangasem, Bali. Pura ini merupakan salah satu dari enam pura utama (Sad Kahyangan Jagad) di Bali dan terkenal dengan "Gerbang Surga" yang menawarkan pemandangan Gunung Agung yang menakjubkan.', 'Karangasem, Bali', -8.3721, 115.6254, 275000, 4.9, 'assets/lempuyang.jpg', 'Taman', 1),
        ('Gunung Batur', 'Gunung Batur adalah gunung berapi aktif yang terletak di Kintamani, Kabupaten Bangli, Bali, dengan ketinggian sekitar 1.717 meter di atas permukaan laut (mdpl). Meskipun tidak setinggi Gunung Agung, Gunung Batur sangat populer karena pemandangan matahari terbit yang menakjubkan.', 'Kintamani, Bali', -8.2425, 115.3751, 350000, 4.7, 'assets/gunung_batur.jpg', 'Gunung', 1),
        ('Ubud', 'Ubud adalah pusat seni dan budaya Bali yang terkenal dengan hutan monyet, galeri seni, dan pemandangan sawah yang menakjubkan.', 'Ubud, Bali', -8.5069, 115.2625, 450000, 4.6, 'assets/ubud.jpg', 'Taman', 1),
        ('Jatiluwih Rice Terrace', 'Jatiluwih adalah salah satu tempat wisata terindah di Bali yang menawarkan pemandangan sawah bertingkat yang hijau dan luas.', 'Tabanan, Bali', -8.3645, 115.1313, 200000, 4.5, 'assets/jatiluwih.jpg', 'Taman', 0),
        ('Trunyan Village', 'Desa Trunyan adalah desa tradisional Bali Aga yang memiliki tradisi unik dalam upacara kematian.', 'Bangli, Bali', -8.2278, 115.3881, 300000, 4.2, 'assets/trunyan.jpg', 'Taman', 0),
        ('GWK Cultural Park', 'Garuda Wisnu Kencana Cultural Park adalah taman budaya yang menampilkan patung Garuda Wisnu Kencana yang megah.', 'Badung, Bali', -8.8101, 115.1669, 150000, 4.4, 'assets/gwk.jpg', 'Taman', 0),
        ('Gunung Catur', 'Gunung Catur menawarkan pendakian yang menantang dengan pemandangan yang spektakuler.', 'Tabanan, Bali', -8.2614, 115.1675, 400000, 4.3, 'assets/gunung_catur.webp', 'Gunung', 0)
    ''');
  }

  // User methods
  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUserLocation(
    int userId,
    double lat,
    double lon,
    String? address,
  ) async {
    final db = await database;
    await db.update(
      'users',
      {
        'current_latitude': lat,
        'current_longitude': lon,
        'current_address': address,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    // Save to location history
    await db.insert('user_locations', {
      'user_id': userId,
      'latitude': lat,
      'longitude': lon,
      'address': address,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Destination methods
  Future<List<Map<String, dynamic>>> getDestinations() async {
    final db = await database;
    return await db.query(
      'destinations',
      orderBy: 'is_popular DESC, distance_from_user ASC',
    );
  }

  Future<void> insertDestination(Map<String, dynamic> destination) async {
    final db = await database;
    await db.insert(
      'destinations',
      destination,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> cacheDestinations(
    List<Map<String, dynamic>> destinations,
  ) async {
    final db = await database;
    final batch = db.batch();

    for (var dest in destinations) {
      batch.insert(
        'destinations',
        dest,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getNearbyDestinations(
    double lat,
    double lon,
    double radiusKm,
  ) async {
    final db = await database;

    // Simple distance approximation (not accurate for large distances but good enough for nearby)
    // 1 degree lat/lon ≈ 111 km
    double latRange = radiusKm / 111.0;
    double lonRange = radiusKm / (111.0 * cos(lat * 3.14159 / 180.0));

    return await db.rawQuery(
      '''
      SELECT *, 
        (abs(latitude - ?) + abs(longitude - ?)) AS distance_approx
      FROM destinations
      WHERE latitude IS NOT NULL AND longitude IS NOT NULL
        AND latitude BETWEEN ? AND ?
        AND longitude BETWEEN ? AND ?
      ORDER BY distance_approx ASC
    ''',
      [
        lat,
        lon,
        lat - latRange,
        lat + latRange,
        lon - lonRange,
        lon + lonRange,
      ],
    );
  }

  // Bookmark methods
  Future<int> addBookmark(int userId, int destinationId) async {
    final db = await database;
    print(
      'DatabaseHelper: Adding bookmark for user $userId, destination $destinationId',
    );

    // Check if bookmark already exists
    final existing = await db.query(
      'bookmarks',
      where: 'user_id = ? AND destination_id = ?',
      whereArgs: [userId, destinationId],
    );

    if (existing.isNotEmpty) {
      print('DatabaseHelper: Bookmark already exists');
      return existing.first['id'] as int;
    }

    final result = await db.insert('bookmarks', {
      'user_id': userId,
      'destination_id': destinationId,
      'created_at': DateTime.now().toIso8601String(),
    });

    print('DatabaseHelper: Bookmark added with ID: $result');
    return result;
  }

  Future<int> removeBookmark(int userId, int destinationId) async {
    final db = await database;
    print(
      'DatabaseHelper: Removing bookmark for user $userId, destination $destinationId',
    );

    final result = await db.delete(
      'bookmarks',
      where: 'user_id = ? AND destination_id = ?',
      whereArgs: [userId, destinationId],
    );

    print('DatabaseHelper: Removed $result bookmark(s)');
    return result;
  }

  Future<List<Map<String, dynamic>>> getUserBookmarks(int userId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT d.*, b.created_at as bookmarked_at
      FROM destinations d
      INNER JOIN bookmarks b ON d.id = b.destination_id
      WHERE b.user_id = ?
      ORDER BY b.created_at DESC
    ''',
      [userId],
    );
  }

  // Ticket methods
  Future<List<Map<String, dynamic>>> getTickets() async {
    final db = await database;
    return await db.query('tickets', orderBy: 'booked_at DESC');
  }

  Future<int> insertTicket(Map<String, dynamic> ticket) async {
    final db = await database;
    return await db.insert('tickets', ticket);
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    final db = await database;
    await db.update(
      'tickets',
      {'status': status},
      where: 'ticket_number = ?',
      whereArgs: [ticketId],
    );
  }

  // Debug methods
  Future<void> debugPrintTables() async {
    final db = await database;

    print('=== DEBUG: DESTINATIONS TABLE ===');
    final destinations = await db.query('destinations');
    for (var dest in destinations) {
      print('Destination: ${dest['id']} - ${dest['name']}');
    }

    print('=== DEBUG: BOOKMARKS TABLE ===');
    final bookmarks = await db.query('bookmarks');
    for (var bookmark in bookmarks) {
      print(
        'Bookmark: User ${bookmark['user_id']} -> Destination ${bookmark['destination_id']}',
      );
    }
  }

  Future<bool> isBookmarked(int userId, int destinationId) async {
    final db = await database;
    final result = await db.query(
      'bookmarks',
      where: 'user_id = ? AND destination_id = ?',
      whereArgs: [userId, destinationId],
    );
    return result.isNotEmpty;
  }
}
