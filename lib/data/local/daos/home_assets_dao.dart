import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/home_assets.dart';

part 'home_assets_dao.g.dart';

/// Data Access Object for HomeAssets
/// 
/// Manages home assets (appliances, electronics, furniture, etc.)
@DriftAccessor(tables: [HomeAssets])
class HomeAssetsDao extends DatabaseAccessor<AppDatabase> with _$HomeAssetsDaoMixin {
  HomeAssetsDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new home asset
  Future<int> createHomeAsset(HomeAssetsCompanion asset) {
    return into(homeAssets).insert(asset);
  }

  /// Create multiple home assets
  Future<void> createHomeAssets(List<HomeAssetsCompanion> assetList) async {
    await batch((batch) {
      batch.insertAll(homeAssets, assetList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a home asset by ID
  Future<HomeAssetEntity?> getHomeAssetById(int id) {
    return (select(homeAssets)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all home assets
  Future<List<HomeAssetEntity>> getAllHomeAssets() {
    return (select(homeAssets)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.purchaseDate)]))
        .get();
  }

  /// Get home assets by type
  Future<List<HomeAssetEntity>> getHomeAssetsByType(String assetType) {
    return (select(homeAssets)
          ..where((t) => t.assetType.equals(assetType))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get home assets by category
  Future<List<HomeAssetEntity>> getHomeAssetsByCategory(String category) {
    return (select(homeAssets)
          ..where((t) => t.category.equals(category))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get home assets by status
  Future<List<HomeAssetEntity>> getHomeAssetsByStatus(String status) {
    return (select(homeAssets)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get active home assets
  Future<List<HomeAssetEntity>> getActiveHomeAssets() {
    return getHomeAssetsByStatus('active');
  }

  /// Get home assets by room
  Future<List<HomeAssetEntity>> getHomeAssetsByRoom(String room) {
    return (select(homeAssets)
          ..where((t) => t.room.equals(room))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get home assets by brand
  Future<List<HomeAssetEntity>> getHomeAssetsByBrand(String brand) {
    return (select(homeAssets)
          ..where((t) => t.brand.equals(brand))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get home assets with warranty
  Future<List<HomeAssetEntity>> getHomeAssetsWithWarranty() {
    return (select(homeAssets)
          ..where((t) => t.hasWarranty.equals(true))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get home assets with expiring warranties (within days)
  Future<List<HomeAssetEntity>> getHomeAssetsWithExpiringWarranty(int daysAhead) {
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    return (select(homeAssets)
          ..where((t) => t.warrantyExpiryDate.isSmallerThanValue(cutoffDate))
          ..where((t) => t.warrantyExpiryDate.isBiggerThanValue(DateTime.now()))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.warrantyExpiryDate)]))
        .get();
  }

  /// Get insured home assets
  Future<List<HomeAssetEntity>> getInsuredHomeAssets() {
    return (select(homeAssets)
          ..where((t) => t.isInsured.equals(true))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get home assets needing service
  Future<List<HomeAssetEntity>> getHomeAssetsNeedingService() {
    final now = DateTime.now();
    return (select(homeAssets)
          ..where((t) => t.nextServiceDue.isSmallerThanValue(now))
          ..where((t) => t.nextServiceDue.isNotNull())
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextServiceDue)]))
        .get();
  }

  /// Get home assets needing replacement
  Future<List<HomeAssetEntity>> getHomeAssetsNeedingReplacement() {
    return (select(homeAssets)
          ..where((t) => t.needsReplacement.equals(true))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get faulty home assets
  Future<List<HomeAssetEntity>> getFaultyHomeAssets() {
    return getHomeAssetsByStatus('faulty');
  }

  /// Get appliances
  Future<List<HomeAssetEntity>> getAppliances() {
    return getHomeAssetsByType('appliance');
  }

  /// Get electronics
  Future<List<HomeAssetEntity>> getElectronics() {
    return getHomeAssetsByType('electronics');
  }

  /// Get furniture
  Future<List<HomeAssetEntity>> getFurniture() {
    return getHomeAssetsByType('furniture');
  }

  /// Search home assets by name or model
  Future<List<HomeAssetEntity>> searchHomeAssets(String query) {
    final pattern = '%$query%';
    return (select(homeAssets)
          ..where((t) =>
              t.assetName.like(pattern) |
              t.model.like(pattern) |
              t.brand.like(pattern))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Stream all home assets
  Stream<List<HomeAssetEntity>> watchAllHomeAssets() {
    return (select(homeAssets)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.purchaseDate)]))
        .watch();
  }

  /// Stream home assets by room
  Stream<List<HomeAssetEntity>> watchHomeAssetsByRoom(String room) {
    return (select(homeAssets)
          ..where((t) => t.room.equals(room))
          ..where((t) => t.deletedAt.isNull()))
        .watch();
  }

  /// Stream home assets by status
  Stream<List<HomeAssetEntity>> watchHomeAssetsByStatus(String status) {
    return (select(homeAssets)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull()))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a home asset
  Future<bool> updateHomeAsset(HomeAssetEntity asset) {
    return update(homeAssets).replace(asset);
  }

  /// Update asset value
  Future<int> updateAssetValue(int id, int valueCents) {
    return (update(homeAssets)..where((t) => t.id.equals(id))).write(
      HomeAssetsCompanion(
        currentValueCents: Value(valueCents),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update asset location
  Future<int> updateAssetLocation(int id, String room, {String? location}) {
    return (update(homeAssets)..where((t) => t.id.equals(id))).write(
      HomeAssetsCompanion(
        room: Value(room),
        location: Value(location),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update asset status
  Future<int> updateAssetStatus(int id, String status) {
    return (update(homeAssets)..where((t) => t.id.equals(id))).write(
      HomeAssetsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark asset as faulty
  Future<int> markAssetAsFaulty(int id) {
    return updateAssetStatus(id, 'faulty');
  }

  /// Mark asset as needing replacement
  Future<int> markAssetNeedsReplacement(int id, bool needsReplacement) {
    return (update(homeAssets)..where((t) => t.id.equals(id))).write(
      HomeAssetsCompanion(
        needsReplacement: Value(needsReplacement),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Record service
  Future<int> recordService(int id, DateTime serviceDate, {DateTime? nextServiceDue, int? serviceCostCents}) {
    return (update(homeAssets)..where((t) => t.id.equals(id))).write(
      HomeAssetsCompanion(
        lastServiceDate: Value(serviceDate),
        nextServiceDue: Value(nextServiceDue),
        serviceCostCents: Value(serviceCostCents),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update warranty
  Future<int> updateWarranty(int id, {
    required bool hasWarranty,
    DateTime? warrantyStartDate,
    DateTime? warrantyExpiryDate,
    int? warrantyDurationMonths,
    String? warrantyProvider,
  }) {
    return (update(homeAssets)..where((t) => t.id.equals(id))).write(
      HomeAssetsCompanion(
        hasWarranty: Value(hasWarranty),
        warrantyStartDate: Value(warrantyStartDate),
        warrantyExpiryDate: Value(warrantyExpiryDate),
        warrantyDurationMonths: Value(warrantyDurationMonths),
        warrantyProvider: Value(warrantyProvider),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark asset as disposed
  Future<int> markAssetAsDisposed(int id, DateTime disposalDate, String disposalMethod) {
    return (update(homeAssets)..where((t) => t.id.equals(id))).write(
      HomeAssetsCompanion(
        status: const Value('disposed'),
        disposalDate: Value(disposalDate),
        disposalMethod: Value(disposalMethod),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark asset as sold
  Future<int> markAssetAsSold(int id, DateTime soldDate) {
    return markAssetAsDisposed(id, soldDate, 'sold');
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a home asset
  Future<int> softDeleteHomeAsset(int id) {
    return (update(homeAssets)..where((t) => t.id.equals(id))).write(
      HomeAssetsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a home asset
  Future<int> hardDeleteHomeAsset(int id) {
    return (delete(homeAssets)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted home asset
  Future<int> restoreHomeAsset(int id) {
    return (update(homeAssets)..where((t) => t.id.equals(id))).write(
      const HomeAssetsCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Calculate total asset value (purchase price)
  Future<int> calculateTotalPurchaseValue() async {
    final allAssets = await getActiveHomeAssets();
    int total = 0;
    for (final asset in allAssets) {
      if (asset.purchasePriceCents != null) {
        total += asset.purchasePriceCents!;
      }
    }
    return total;
  }

  /// Calculate total current value
  Future<int> calculateTotalCurrentValue() async {
    final allAssets = await getActiveHomeAssets();
    int total = 0;
    for (final asset in allAssets) {
      if (asset.currentValueCents != null) {
        total += asset.currentValueCents!;
      }
    }
    return total;
  }

  /// Calculate depreciation (purchase value - current value)
  Future<int> calculateTotalDepreciation() async {
    final purchaseValue = await calculateTotalPurchaseValue();
    final currentValue = await calculateTotalCurrentValue();
    return purchaseValue - currentValue;
  }

  /// Calculate total value by room
  Future<int> calculateValueByRoom(String room) async {
    final roomAssets = await getHomeAssetsByRoom(room);
    int total = 0;
    for (final asset in roomAssets) {
      if (asset.currentValueCents != null) {
        total += asset.currentValueCents!;
      }
    }
    return total;
  }

  /// Count assets by type
  Future<int> countAssetsByType(String assetType) async {
    final query = selectOnly(homeAssets)
      ..addColumns([homeAssets.id.count()])
      ..where(homeAssets.assetType.equals(assetType))
      ..where(homeAssets.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(homeAssets.id.count()) ?? 0;
  }

  /// Count assets by status
  Future<int> countAssetsByStatus(String status) async {
    final query = selectOnly(homeAssets)
      ..addColumns([homeAssets.id.count()])
      ..where(homeAssets.status.equals(status))
      ..where(homeAssets.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(homeAssets.id.count()) ?? 0;
  }

  /// Count assets by room
  Future<int> countAssetsByRoom(String room) async {
    final query = selectOnly(homeAssets)
      ..addColumns([homeAssets.id.count()])
      ..where(homeAssets.room.equals(room))
      ..where(homeAssets.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(homeAssets.id.count()) ?? 0;
  }

  /// Count assets with warranty
  Future<int> countAssetsWithWarranty() async {
    final query = selectOnly(homeAssets)
      ..addColumns([homeAssets.id.count()])
      ..where(homeAssets.hasWarranty.equals(true))
      ..where(homeAssets.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(homeAssets.id.count()) ?? 0;
  }

  /// Count insured assets
  Future<int> countInsuredAssets() async {
    final query = selectOnly(homeAssets)
      ..addColumns([homeAssets.id.count()])
      ..where(homeAssets.isInsured.equals(true))
      ..where(homeAssets.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(homeAssets.id.count()) ?? 0;
  }
}



