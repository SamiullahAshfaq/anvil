import '../../domain/entities/stock_position.dart';
import 'database.dart';

/// Maps generated Drift rows to pure-domain value objects, so the domain services
/// operate on plain entities and never see Drift types.
extension StockCategoryMapper on StockCategory {
  StockPosition toStockPosition() => StockPosition(
        quantityGrams: quantityGrams,
        totalCostBasisPaisa: totalCostBasisPaisa,
      );
}
