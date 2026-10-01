import '../models/bill_list_item.dart';

class BillListState {
  const BillListState({this.items = const []});

  final List<BillListItem> items;
}
