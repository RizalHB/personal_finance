import '../../domain/entities/bill.dart';
import 'bill_list_item.dart';

class BillListItemMapper {
  const BillListItemMapper();

  BillListItem map(Bill bill) {
    return BillListItem(
      billId: bill.id,
      name: bill.name,
      amountMinor: bill.amountMinor,
      currencyCode: bill.currencyCode,
      dueDate: bill.dueDate,
      statusLabel: _statusLabel(bill.status),
      isActive: bill.status == BillStatus.active,
    );
  }

  List<BillListItem> mapList(List<Bill> bills) {
    return bills.map(map).toList();
  }

  String _statusLabel(BillStatus status) {
    switch (status) {
      case BillStatus.active:
        return 'Active';
      case BillStatus.paid:
        return 'Paid';
      case BillStatus.cancelled:
        return 'Cancelled';
    }
  }
}
