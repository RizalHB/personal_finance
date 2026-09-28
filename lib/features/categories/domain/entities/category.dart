enum CategoryType {
  income(1),
  expense(2);

  const CategoryType(this.code);

  final int code;

  static CategoryType fromCode(int code) {
    for (final type in values) {
      if (type.code == code) {
        return type;
      }
    }

    throw ArgumentError('Unknown category type code: $code');
  }
}

enum CategoryStatus {
  active(1),
  archived(2);

  const CategoryStatus(this.code);

  final int code;

  static CategoryStatus fromCode(int code) {
    for (final status in values) {
      if (status.code == code) {
        return status;
      }
    }

    throw ArgumentError('Unknown category status code: $code');
  }
}

class Category {
  const Category({
    required this.id,
    required this.ledgerAccountId,
    required this.parentId,
    required this.name,
    required this.categoryType,
    required this.status,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.archivedAt,
  });

  final String id;
  final String ledgerAccountId;
  final String? parentId;
  final String name;
  final CategoryType categoryType;
  final CategoryStatus status;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;
  final int? archivedAt;
}
