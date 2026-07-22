import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/ids.dart';
import '../../data/local/database.dart';
import '../../security/access_mode.dart';
import 'use_case_result.dart';

/// Creates custom **parent** stock categories inline (03_RULES.md §9 — no
/// separate manage-categories detour) and edits a category's target margin %
/// (the recommended-rate setting, 01_PRD.md §4.3). Sub-categories are never
/// created here — they are free-text tags on bill lines (§1.16).
class ManageStock {
  final AppDatabase db;
  final AccessController access;

  const ManageStock({required this.db, required this.access});

  Future<UseCaseResult<String>> createCategory(String name) async {
    access.ensureCanMutate();
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('A category needs a name.');
    }
    try {
      final id = newId();
      await db.into(db.stockCategories).insert(StockCategoriesCompanion.insert(
            id: id,
            name: trimmed,
            isCustom: const Value(true),
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

  Future<UseCaseResult<void>> setTargetMargin(
      String categoryId, int marginPct) async {
    access.ensureCanMutate();
    if (marginPct < 0) {
      throw const ValidationException('Margin cannot be negative.');
    }
    try {
      await (db.update(db.stockCategories)
            ..where((t) => t.id.equals(categoryId)))
          .write(StockCategoriesCompanion(targetMarginPct: Value(marginPct)));
      return const Success(null);
    } on AppException {
      rethrow;
    } catch (e) {
      throw TransactionFailedException(
          'Something didn\'t save — nothing was changed, try again.', e);
    }
  }
}
