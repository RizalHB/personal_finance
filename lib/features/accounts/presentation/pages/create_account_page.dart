import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/account_providers.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({super.key});

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _institutionController = TextEditingController();

  int _financialClass = 1;
  int _accountType = 2;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(createAccountProvider)
          .execute(
            name: _nameController.text,
            financialClass: _financialClass,
            accountType: _accountType,
            currencyCode: 'IDR',
            openingBalanceMinor: 0,
            institutionName: _institutionController.text,
          );

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat rekening: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Rekening')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nama rekening',
                hintText: 'Contoh: BCA Utama',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama rekening wajib diisi.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _financialClass,
              decoration: const InputDecoration(
                labelText: 'Jenis keuangan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Aset')),
                DropdownMenuItem(value: 2, child: Text('Kewajiban')),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _financialClass = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _accountType,
              decoration: const InputDecoration(
                labelText: 'Tipe rekening',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Tunai')),
                DropdownMenuItem(value: 2, child: Text('Bank')),
                DropdownMenuItem(value: 3, child: Text('E-Wallet')),
                DropdownMenuItem(value: 4, child: Text('Tabungan')),
                DropdownMenuItem(value: 5, child: Text('Kartu Kredit')),
                DropdownMenuItem(value: 6, child: Text('Investasi')),
                DropdownMenuItem(value: 7, child: Text('Lainnya')),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _accountType = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _institutionController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Institusi',
                hintText: 'Contoh: Bank Central Asia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
