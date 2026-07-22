import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../data/local/stock_rebuild.dart';
import '../../security/access_mode.dart';
import 'use_case_result.dart';

/// Soft-delete retention window before auto-purge (01_PRD.md §4.8, 03_RULES.md
/// §1.11).
const trashRetentionDays = 30;

const _billEntity = 'bill';
const _partyEntity = 'party';

/// Every delete is a **soft** delete → a [TrashRecord] with a 30-day purge date,
/// fully recoverable (03_RULES.md §1.11). Deleting/restoring a stock-affecting
/// bill keeps the stored moving-average totals exact by *replaying* the surviving
/// ledger (see [StockRebuild]) rather than approximating an inverse. Cash effects
/// are unwound by soft-deleting the bill's own cash movements + advance payments;
/// party balances self-correct because they are derived from non-deleted rows.
class TrashService {
  final AppDatabase db;
  final AccessController access;

  const TrashService({required this.db, required this.access});

  DateTime _purgeAt(DateTime from) =>
      from.add(const Duration(days: trashRetentionDays));

  Future<List<String>> _affectedCategories(String billId) async {
    final lines = await (db.select(db.billLineItems)
          ..where((t) => t.billId.equals(billId)))
        .get();
    return lines.map((l) => l.parentCategoryId).toSet().toList(growable: false);
  }

  Future<List<String>> _relatedPaymentIds(String billId) async {
    final movements = await (db.select(db.cashMovements)
          ..where((t) => t.relatedBillId.equals(billId)))
        .get();
    return movements
        .map((m) => m.relatedPaymentId)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
  }

  Future<UseCaseResult<void>> softDeleteBill(String billId) async {
    access.ensureCanMutate();
    try {
      await db.transaction(() async {
        final bill = await (db.select(db.bills)
              ..where((t) => t.id.equals(billId)))
            .getSingleOrNull();
        if (bill == null || bill.deletedAt != null) return;

        final now = DateTime.now();
        final categories = await _affectedCategories(billId);
        final paymentIds = await _relatedPaymentIds(billId);

        await (db.update(db.bills)..where((t) => t.id.equals(billId)))
            .write(BillsCompanion(deletedAt: Value(now)));
        await (db.update(db.cashMovements)
              ..where((t) => t.relatedBillId.equals(billId)))
            .write(CashMovementsCompanion(deletedAt: Value(now)));
        for (final pid in paymentIds) {
          await (db.update(db.payments)..where((t) => t.id.equals(pid)))
              .write(PaymentsCompanion(deletedAt: Value(now)));
        }
        for (final catId in categories) {
          await db.rebuildCategoryStock(catId);
        }
        await db.into(db.trashRecords).insert(TrashRecordsCompanion.insert(
              id: newId(),
              entityType: _billEntity,
              entityId: billId,
              deletedAt: now,
              purgeAt: _purgeAt(now),
            ));
      });
      return const Success(null);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }

  Future<UseCaseResult<void>> restoreBill(String billId) async {
    access.ensureCanMutate();
    try {
      await db.transaction(() async {
        final categories = await _affectedCategories(billId);
        final paymentIds = await _relatedPaymentIds(billId);

        await (db.update(db.bills)..where((t) => t.id.equals(billId)))
            .write(const BillsCompanion(deletedAt: Value(null)));
        await (db.update(db.cashMovements)
              ..where((t) => t.relatedBillId.equals(billId)))
            .write(const CashMovementsCompanion(deletedAt: Value(null)));
        for (final pid in paymentIds) {
          await (db.update(db.payments)..where((t) => t.id.equals(pid)))
              .write(const PaymentsCompanion(deletedAt: Value(null)));
        }
        for (final catId in categories) {
          await db.rebuildCategoryStock(catId);
        }
        await (db.delete(db.trashRecords)
              ..where((t) => t.entityId.equals(billId)))
            .go();
      });
      return const Success(null);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }

  Future<UseCaseResult<void>> softDeleteParty(String partyId) async {
    access.ensureCanMutate();
    try {
      await db.transaction(() async {
        final openBills = await (db.select(db.bills)
              ..where((t) => t.partyId.equals(partyId) & t.deletedAt.isNull()))
            .get();
        final openPayments = await (db.select(db.payments)
              ..where((t) => t.partyId.equals(partyId) & t.deletedAt.isNull()))
            .get();
        if (openBills.isNotEmpty || openPayments.isNotEmpty) {
          throw const ValidationException(
              'This party still has bills or payments. Remove those first, then delete the party.');
        }
        final now = DateTime.now();
        await (db.update(db.parties)..where((t) => t.id.equals(partyId)))
            .write(PartiesCompanion(deletedAt: Value(now)));
        await db.into(db.trashRecords).insert(TrashRecordsCompanion.insert(
              id: newId(),
              entityType: _partyEntity,
              entityId: partyId,
              deletedAt: now,
              purgeAt: _purgeAt(now),
            ));
      });
      return const Success(null);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }

  Future<UseCaseResult<void>> restoreParty(String partyId) async {
    access.ensureCanMutate();
    try {
      await db.transaction(() async {
        await (db.update(db.parties)..where((t) => t.id.equals(partyId)))
            .write(const PartiesCompanion(deletedAt: Value(null)));
        await (db.delete(db.trashRecords)
              ..where((t) => t.entityId.equals(partyId)))
            .go();
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
