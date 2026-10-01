import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/bill_dependencies.dart';
import '../models/bill_list_item_mapper.dart';
import '../state/bill_list_state.dart';

class BillListNotifier extends AsyncNotifier<BillListState> {
  @override
  Future<BillListState> build() async {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(_load);
  }

  Future<BillListState> _load() async {
    final useCase = ref.read(getBillsProvider);
    const mapper = BillListItemMapper();

    final bills = await useCase.execute();

    return BillListState(items: mapper.mapList(bills));
  }
}

final billListNotifierProvider =
    AsyncNotifierProvider<BillListNotifier, BillListState>(
      BillListNotifier.new,
    );
