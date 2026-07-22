import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../data/local/tables.dart';
import '../../security/access_mode.dart';
import 'use_case_result.dart';

/// Creates or edits a Party. A party is a single-table record, but writes still
/// go through a use-case so View-mode is enforced (03_RULES.md §1.22) and every
/// field edit is logged to `UpdateHistory` in the same transaction (§1.19).
class ManageParty {
  final AppDatabase db;
  final AccessController access;

  const ManageParty({required this.db, required this.access});

  Future<UseCaseResult<String>> create({
    required String name,
    required PartyTypeDb type,
    String? phone,
  }) async {
    access.ensureCanMutate();
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('A party needs a name.');
    }
    try {
      final id = newId();
      await db.into(db.parties).insert(PartiesCompanion.insert(
            id: id,
            name: trimmed,
            type: type,
            phone: Value(phone?.trim().isEmpty ?? true ? null : phone!.trim()),
            createdAt: DateTime.now(),
          ));
      return Success(id);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }

  Future<UseCaseResult<void>> edit({
    required String partyId,
    String? name,
    PartyTypeDb? type,
    String? phone,
  }) async {
    access.ensureCanMutate();
    try {
      await db.transaction(() async {
        final party = await (db.select(db.parties)
              ..where((t) => t.id.equals(partyId)))
            .getSingle();
        final now = DateTime.now();
        final history = <UpdateHistoriesCompanion>[];

        void logIfChanged(String field, String? oldV, String? newV) {
          if (newV != null && newV != oldV) {
            history.add(UpdateHistoriesCompanion.insert(
              id: newId(),
              entityType: 'party',
              entityId: partyId,
              fieldChanged: field,
              oldValue: Value(oldV),
              newValue: Value(newV),
              changedAt: now,
            ));
          }
        }

        final newName = name?.trim();
        logIfChanged('name', party.name, newName);
        logIfChanged('type', party.type.name, type?.name);
        logIfChanged('phone', party.phone, phone?.trim());

        if (history.isEmpty) return;
        await (db.update(db.parties)..where((t) => t.id.equals(partyId)))
            .write(PartiesCompanion(
          name: newName == null ? const Value.absent() : Value(newName),
          type: type == null ? const Value.absent() : Value(type),
          phone: phone == null ? const Value.absent() : Value(phone.trim()),
        ));
        await db.batch((b) => b.insertAll(db.updateHistories, history));
      });
      return const Success(null);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }
}
