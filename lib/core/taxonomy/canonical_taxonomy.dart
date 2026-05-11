import 'package:flutter/material.dart';

/// Canonical domain and category identifiers — aligned with the master
/// taxonomy spec (MASTER_CONTEXT_DELTA_v2.md).
///
/// These string IDs are the single source of truth for:
///   - [DocumentEntity.domainId]
///   - [DocumentEntity.categoryId]
///   - UI labels, icon selection, and route targets
///
/// The legacy [Domain] enum in `domain.dart` is preserved for backward
/// compatibility. Use these constants for all new code.

// ── Domain IDs ────────────────────────────────────────────────────────────────

abstract final class DomainIds {
  static const identityLegal = 'identity_legal';
  static const homeProperty = 'home_property';
  static const vehiclesTransport = 'vehicles_transport';
  static const bankingCreditBorrowing = 'banking_credit_borrowing';
  static const insuranceProtection = 'insurance_protection';
  static const billsUtilitiesSubscriptions = 'bills_utilities_subscriptions';
  static const workIncomeTax = 'work_income_tax';
}

// ── Category IDs ──────────────────────────────────────────────────────────────

abstract final class CategoryIds {
  // identity_legal
  static const personalIdentity = 'personal_identity';
  static const visaResidence = 'visa_residence';
  static const legalCertificates = 'legal_certificates';

  // home_property
  static const mortgageRent = 'mortgage_rent';
  static const councilTax = 'council_tax';
  static const homeInsurance = 'home_insurance';
  static const homeMaintenance = 'home_maintenance';
  static const homeAssets = 'home_assets';

  // vehicles_transport
  static const vehicleOwnership = 'vehicle_ownership';
  static const vehicleInsurance = 'vehicle_insurance';
  static const vehicleCompliance = 'vehicle_compliance';
  static const vehicleMaintenance = 'vehicle_maintenance';

  // banking_credit_borrowing
  static const bankAccounts = 'bank_accounts';
  static const creditCards = 'credit_cards';
  static const loans = 'loans';
  static const mortgageFinance = 'mortgage_finance';

  // insurance_protection
  static const lifeInsurance = 'life_insurance';
  static const healthInsurance = 'health_insurance';
  static const travelInsurance = 'travel_insurance';
  static const petInsurance = 'pet_insurance';

  // bills_utilities_subscriptions
  static const utilities = 'utilities';
  static const streaming = 'streaming';
  static const mobile = 'mobile';
  static const gymFitness = 'gym_fitness';
  static const cloudStorage = 'cloud_storage';

  // work_income_tax
  static const employment = 'employment';
  static const selfEmployment = 'self_employment';
  static const taxRecords = 'tax_records';
  static const pensions = 'pensions';
}

// ── Domain descriptors (for UI rendering) ────────────────────────────────────

class DomainDescriptor {
  final String id;
  final String displayName;
  final IconData icon;
  final Color Function(ColorScheme cs) iconColor;
  final Color Function(ColorScheme cs) iconBackground;
  final String? featureRoute;

  const DomainDescriptor({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.featureRoute,
  });
}

final List<DomainDescriptor> canonicalDomains = [
  DomainDescriptor(
    id: DomainIds.identityLegal,
    displayName: 'Identity',
    icon: Icons.badge_outlined,
    iconColor: (cs) => cs.onPrimaryContainer,
    iconBackground: (cs) => cs.primaryContainer,
    featureRoute: '/vault/category/${DomainIds.identityLegal}',
  ),
  DomainDescriptor(
    id: DomainIds.homeProperty,
    displayName: 'Home',
    icon: Icons.home_outlined,
    iconColor: (cs) => cs.onSecondaryContainer,
    iconBackground: (cs) => cs.secondaryContainer,
    featureRoute: '/vault/category/${DomainIds.homeProperty}',
  ),
  DomainDescriptor(
    id: DomainIds.vehiclesTransport,
    displayName: 'Vehicle',
    icon: Icons.directions_car_outlined,
    iconColor: (cs) => cs.onTertiaryContainer,
    iconBackground: (cs) => cs.tertiaryContainer,
    featureRoute: '/vault/category/${DomainIds.vehiclesTransport}',
  ),
  DomainDescriptor(
    id: DomainIds.bankingCreditBorrowing,
    displayName: 'Banking',
    icon: Icons.account_balance_outlined,
    iconColor: (cs) => cs.onPrimaryContainer,
    iconBackground: (cs) => cs.primaryContainer,
    featureRoute: '/vault/category/${DomainIds.bankingCreditBorrowing}',
  ),
  DomainDescriptor(
    id: DomainIds.insuranceProtection,
    displayName: 'Insurance',
    icon: Icons.shield_outlined,
    iconColor: (cs) => cs.onSecondaryContainer,
    iconBackground: (cs) => cs.secondaryContainer,
    featureRoute: '/vault/category/${DomainIds.insuranceProtection}',
  ),
  DomainDescriptor(
    id: DomainIds.billsUtilitiesSubscriptions,
    displayName: 'Subscriptions',
    icon: Icons.subscriptions_outlined,
    iconColor: (cs) => cs.onTertiaryContainer,
    iconBackground: (cs) => cs.tertiaryContainer,
    featureRoute: '/vault/category/${DomainIds.billsUtilitiesSubscriptions}',
  ),
  DomainDescriptor(
    id: DomainIds.workIncomeTax,
    displayName: 'Work',
    icon: Icons.work_outline,
    iconColor: (cs) => cs.onPrimaryContainer,
    iconBackground: (cs) => cs.primaryContainer,
    featureRoute: '/vault/category/${DomainIds.workIncomeTax}',
  ),
];
