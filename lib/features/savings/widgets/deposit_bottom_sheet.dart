import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/saving_deposit.dart';
import '../../../data/models/saving_goal.dart';
import '../../../shared/providers/savings_provider.dart';
import '../utils/saving_icon_helper.dart';

class DepositBottomSheet extends ConsumerStatefulWidget {
  final SavingGoal? initialGoal;
  
  const DepositBottomSheet({super.key, this.initialGoal});

  @override
  ConsumerState<DepositBottomSheet> createState() => _DepositBottomSheetState();
}

class _DepositBottomSheetState extends ConsumerState<DepositBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedGoalId;

  @override
  void initState() {
    super.initState();
    if (widget.initialGoal != null) {
      _selectedGoalId = widget.initialGoal!.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveDeposit() {
    if (_formKey.currentState!.validate() && _selectedGoalId != null) {
      final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      
      final deposit = SavingDeposit(
        id: const Uuid().v4(),
        goalId: _selectedGoalId!,
        amount: amount,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      ref.read(savingsProvider.notifier).addDeposit(deposit);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final savingsState = ref.watch(savingsProvider);
    final goals = savingsState.goals;

    if (goals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Text('Silakan buat goal tabungan terlebih dahulu.'),
      );
    }

    if (_selectedGoalId == null && goals.isNotEmpty) {
      _selectedGoalId = goals.first.id;
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Setor Tabungan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              DropdownButtonFormField<String>(
                value: _selectedGoalId,
                decoration: const InputDecoration(
                  labelText: 'Pilih Goal',
                  border: OutlineInputBorder(),
                ),
                items: goals.map((g) {
                  return DropdownMenuItem(
                    value: g.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(SavingIconHelper.getIcon(g.icon), size: 16),
                        const SizedBox(width: 8),
                        Text(g.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGoalId = val);
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Setoran (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricTeal,
                    foregroundColor: AppColors.deepNavy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveDeposit,
                  child: const Text('Setor Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
