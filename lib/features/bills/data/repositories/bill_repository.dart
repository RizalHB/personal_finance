import '../../domain/entities/bill.dart';

abstract interface class BillRepository {
  Future<Bill?> getById(String id);

  Future<List<Bill>> getAll();

  Future<Bill> create({required Bill bill});

  Future<Bill> update({required Bill bill});

  Future<void> delete(String id);
}
