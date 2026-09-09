class Account {
  const Account({
    required this.id,
    required this.name,
    required this.financialClass,
    required this.accountType,
    required this.currencyCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.institutionName,
    this.iconCode,
    this.colorCode,
    this.notes,
    this.archivedAt,
  });

  final String id;
  final String name;
  final int financialClass;
  final int accountType;
  final String currencyCode;
  final int status;
  final int createdAt;
  final int updatedAt;
  final String? institutionName;
  final String? iconCode;
  final String? colorCode;
  final String? notes;
  final int? archivedAt;
}
