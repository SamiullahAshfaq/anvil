import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a client-side UUIDv4 for a primary/foreign key. Every PK/FK in the
/// schema is created this way — never a DB auto-increment (03_RULES.md §1.17).
String newId() => _uuid.v4();
