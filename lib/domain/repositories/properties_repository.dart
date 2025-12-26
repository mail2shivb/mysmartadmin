import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for property operations
/// 
/// Thin layer above propertiesDao - delegates to existing DAO methods
class PropertiesRepository {
  final AppDatabase _database;

  PropertiesRepository(this._database);

  /// Add a new property
  Future<int> addProperty({
    required String propertyName,
    required String addressLine1,
    required String city,
    required String postcode,
    required String propertyType,
    required String ownership,
    String? addressLine2,
    String? country,
    int? currentValueCents,
    int? purchasePriceCents,
    DateTime? purchaseDate,
    DateTime? moveInDate,
    bool isPrimaryResidence = false,
  }) {
    return _database.propertiesDao.createProperty(
      PropertiesCompanion.insert(
        propertyName: propertyName,
        addressLine1: addressLine1,
        city: city,
        postcode: postcode,
        propertyType: propertyType,
        ownership: ownership,
        addressLine2: Value(addressLine2),
        country: Value(country ?? 'UK'),
        currentValueCents: Value(currentValueCents),
        purchasePriceCents: Value(purchasePriceCents),
        purchaseDate: Value(purchaseDate),
        moveInDate: Value(moveInDate),
        isPrimaryResidence: Value(isPrimaryResidence),
      ),
    );
  }

  /// Stream all properties (excluding soft deleted)
  Stream<List<PropertyEntity>> watchAllProperties() {
    return _database.propertiesDao.watchAllProperties();
  }

  /// Get a single property by ID
  Future<PropertyEntity?> getPropertyById(int id) {
    return _database.propertiesDao.getPropertyById(id);
  }

  /// Update an existing property
  Future<bool> updateProperty(PropertyEntity property) {
    return _database.propertiesDao.updateProperty(property);
  }

  /// Soft delete a property (can be restored later)
  Future<int> softDeleteProperty(int id) {
    return _database.propertiesDao.softDeleteProperty(id);
  }
}

