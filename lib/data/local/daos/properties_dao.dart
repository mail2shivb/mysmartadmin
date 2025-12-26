import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/properties.dart';

part 'properties_dao.g.dart';

/// Data Access Object for Properties
/// 
/// Manages properties (owned, rented, leasehold, etc.)
@DriftAccessor(tables: [Properties])
class PropertiesDao extends DatabaseAccessor<AppDatabase> with _$PropertiesDaoMixin {
  PropertiesDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new property
  Future<int> createProperty(PropertiesCompanion property) {
    return into(properties).insert(property);
  }

  /// Create multiple properties
  Future<void> createProperties(List<PropertiesCompanion> propertyList) async {
    await batch((batch) {
      batch.insertAll(properties, propertyList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a property by ID
  Future<PropertyEntity?> getPropertyById(int id) {
    return (select(properties)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all properties
  Future<List<PropertyEntity>> getAllProperties() {
    return (select(properties)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.isPrimaryResidence)]))
        .get();
  }

  /// Get properties by type
  Future<List<PropertyEntity>> getPropertiesByType(String propertyType) {
    return (select(properties)
          ..where((t) => t.propertyType.equals(propertyType))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get properties by ownership
  Future<List<PropertyEntity>> getPropertiesByOwnership(String ownership) {
    return (select(properties)
          ..where((t) => t.ownership.equals(ownership))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get properties by status
  Future<List<PropertyEntity>> getPropertiesByStatus(String status) {
    return (select(properties)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get primary residence
  Future<PropertyEntity?> getPrimaryResidence() {
    return (select(properties)
          ..where((t) => t.isPrimaryResidence.equals(true))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get owned properties
  Future<List<PropertyEntity>> getOwnedProperties() {
    return (select(properties)
          ..where((t) => t.ownership.equals('owned') | t.ownership.equals('mortgaged'))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get rented properties
  Future<List<PropertyEntity>> getRentedProperties() {
    return getPropertiesByOwnership('rented');
  }

  /// Get properties with expiring leases (within days)
  Future<List<PropertyEntity>> getPropertiesWithExpiringLeases(int daysAhead) {
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    return (select(properties)
          ..where((t) => t.leaseEndDate.isSmallerThanValue(cutoffDate))
          ..where((t) => t.leaseEndDate.isBiggerThanValue(DateTime.now()))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.leaseEndDate)]))
        .get();
  }

  /// Search properties by address
  Future<List<PropertyEntity>> searchPropertiesByAddress(String query) {
    final pattern = '%$query%';
    return (select(properties)
          ..where((t) =>
              t.addressLine1.like(pattern) |
              t.city.like(pattern) |
              t.postcode.like(pattern))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Stream all properties
  Stream<List<PropertyEntity>> watchAllProperties() {
    return (select(properties)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.isPrimaryResidence)]))
        .watch();
  }

  /// Stream properties by status
  Stream<List<PropertyEntity>> watchPropertiesByStatus(String status) {
    return (select(properties)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull()))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a property
  Future<bool> updateProperty(PropertyEntity property) {
    return update(properties).replace(property);
  }

  /// Update property value
  Future<int> updatePropertyValue(int id, int valueCents, DateTime valuationDate) {
    return (update(properties)..where((t) => t.id.equals(id))).write(
      PropertiesCompanion(
        currentValueCents: Value(valueCents),
        lastValuationDate: Value(valuationDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update mortgage balance
  Future<int> updateMortgageBalance(int id, int balanceCents) {
    return (update(properties)..where((t) => t.id.equals(id))).write(
      PropertiesCompanion(
        mortgageBalanceCents: Value(balanceCents),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update property status
  Future<int> updatePropertyStatus(int id, String status) {
    return (update(properties)..where((t) => t.id.equals(id))).write(
      PropertiesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Set as primary residence
  Future<void> setPrimaryResidence(int id) async {
    // First, unset all other properties
    await (update(properties)..where((t) => t.deletedAt.isNull())).write(
      const PropertiesCompanion(
        isPrimaryResidence: Value(false),
      ),
    );
    // Then set the selected property as primary
    await (update(properties)..where((t) => t.id.equals(id))).write(
      PropertiesCompanion(
        isPrimaryResidence: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark property as sold
  Future<int> markPropertyAsSold(int id, DateTime soldDate) {
    return (update(properties)..where((t) => t.id.equals(id))).write(
      PropertiesCompanion(
        status: const Value('sold'),
        moveOutDate: Value(soldDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a property
  Future<int> softDeleteProperty(int id) {
    return (update(properties)..where((t) => t.id.equals(id))).write(
      PropertiesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a property
  Future<int> hardDeleteProperty(int id) {
    return (delete(properties)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted property
  Future<int> restoreProperty(int id) {
    return (update(properties)..where((t) => t.id.equals(id))).write(
      const PropertiesCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Calculate total property value
  Future<int> calculateTotalPropertyValue() async {
    final allProperties = await getOwnedProperties();
    int total = 0;
    for (final property in allProperties) {
      if (property.currentValueCents != null) {
        total += property.currentValueCents!;
      }
    }
    return total;
  }

  /// Calculate total mortgage debt
  Future<int> calculateTotalMortgageDebt() async {
    final allProperties = await getOwnedProperties();
    int total = 0;
    for (final property in allProperties) {
      if (property.mortgageBalanceCents != null) {
        total += property.mortgageBalanceCents!;
      }
    }
    return total;
  }

  /// Calculate net property equity (value - mortgage)
  Future<int> calculateNetPropertyEquity() async {
    final totalValue = await calculateTotalPropertyValue();
    final totalDebt = await calculateTotalMortgageDebt();
    return totalValue - totalDebt;
  }

  /// Count properties by ownership type
  Future<int> countPropertiesByOwnership(String ownership) async {
    final query = selectOnly(properties)
      ..addColumns([properties.id.count()])
      ..where(properties.ownership.equals(ownership))
      ..where(properties.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(properties.id.count()) ?? 0;
  }

  /// Count properties by status
  Future<int> countPropertiesByStatus(String status) async {
    final query = selectOnly(properties)
      ..addColumns([properties.id.count()])
      ..where(properties.status.equals(status))
      ..where(properties.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(properties.id.count()) ?? 0;
  }

  // ============================================================
  // VERSIONING
  // ============================================================

  /// Get property versions
  Future<List<PropertyEntity>> getPropertyVersions(int propertyId) {
    return (select(properties)
          ..where((t) => t.id.equals(propertyId) | t.previousVersionId.equals(propertyId))
          ..orderBy([(t) => OrderingTerm.desc(t.version)]))
        .get();
  }

  /// Create new version of a property
  Future<int> createPropertyVersion(int existingPropertyId, PropertiesCompanion updates) async {
    final existing = await getPropertyById(existingPropertyId);
    if (existing == null) throw Exception('Property not found');

    final newVersion = updates.copyWith(
      version: Value(existing.version + 1),
      previousVersionId: Value(existingPropertyId),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    return into(properties).insert(newVersion);
  }
}

