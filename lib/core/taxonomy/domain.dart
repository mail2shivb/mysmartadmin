import 'package:flutter/material.dart';

/// Top-level domain category
/// 
/// These 8 domains are HARD-CODED as per specification.
/// They represent the primary classification system for all documents.
/// 
/// Derived from UK comparison sites:
/// - MoneySuperMarket
/// - GoCompare
/// - CompareTheMarket
/// - Confused.com
enum Domain {
  identityLegal,
  vehiclesTransport,
  propertyHome,
  insuranceProtection,
  bankingCredit,
  subscriptionsMemberships,
  employmentIncome,
  general;

  /// Human-readable display name
  String get displayName {
    switch (this) {
      case Domain.identityLegal:
        return 'Identity & Legal Documents';
      case Domain.vehiclesTransport:
        return 'Vehicles & Transport';
      case Domain.propertyHome:
        return 'Property & Home';
      case Domain.insuranceProtection:
        return 'Insurance & Protection';
      case Domain.bankingCredit:
        return 'Banking & Credit';
      case Domain.subscriptionsMemberships:
        return 'Subscriptions & Memberships';
      case Domain.employmentIncome:
        return 'Employment & Income';
      case Domain.general:
        return 'General Documents';
    }
  }

  /// Icon for domain
  IconData get icon {
    switch (this) {
      case Domain.identityLegal:
        return Icons.badge;
      case Domain.vehiclesTransport:
        return Icons.directions_car;
      case Domain.propertyHome:
        return Icons.home;
      case Domain.insuranceProtection:
        return Icons.shield;
      case Domain.bankingCredit:
        return Icons.account_balance;
      case Domain.subscriptionsMemberships:
        return Icons.subscriptions;
      case Domain.employmentIncome:
        return Icons.work;
      case Domain.general:
        return Icons.description;
    }
  }

  /// Priority for MVP (Identity & Legal is highest)
  int get priority {
    switch (this) {
      case Domain.identityLegal:
        return 1;
      case Domain.vehiclesTransport:
        return 2;
      case Domain.propertyHome:
        return 3;
      case Domain.insuranceProtection:
        return 4;
      case Domain.bankingCredit:
        return 5;
      case Domain.subscriptionsMemberships:
        return 6;
      case Domain.employmentIncome:
        return 7;
      case Domain.general:
        return 8;
    }
  }
}

