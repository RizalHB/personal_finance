import 'package:uuid/uuid.dart';

import 'id_generator.dart';

class UuidIdGenerator implements IdGenerator {
  UuidIdGenerator([Uuid? uuid]) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  @override
  String generate() {
    return _uuid.v4();
  }
}
