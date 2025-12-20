/// Document type within a domain
/// 
/// Examples:
/// - Identity & Legal: Passport, Driving Licence, Birth Certificate
/// - Vehicles: Insurance Certificate, MOT Certificate, V5C
/// - Property: Mortgage Agreement, Council Tax Bill
/// 
/// Document types are extensible within each domain.
class DocumentType {
  final String id;
  final String displayName;
  final String domainId;

  const DocumentType({
    required this.id,
    required this.displayName,
    required this.domainId,
  });

  /// Pre-defined document types for Identity & Legal domain (MVP)
  static const DocumentType passport = DocumentType(
    id: 'passport',
    displayName: 'Passport',
    domainId: 'identity_legal',
  );

  static const DocumentType drivingLicence = DocumentType(
    id: 'driving_licence',
    displayName: 'Driving Licence',
    domainId: 'identity_legal',
  );

  static const DocumentType birthCertificate = DocumentType(
    id: 'birth_certificate',
    displayName: 'Birth Certificate',
    domainId: 'identity_legal',
  );

  static const DocumentType visa = DocumentType(
    id: 'visa',
    displayName: 'Visa / Residence Permit',
    domainId: 'identity_legal',
  );

  /// All identity & legal document types (MVP)
  static const List<DocumentType> identityLegalTypes = [
    passport,
    drivingLicence,
    birthCertificate,
    visa,
  ];
}

