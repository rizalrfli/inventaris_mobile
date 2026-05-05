import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/saving_goal.dart';
import '../../../shared/providers/savings_provider.dart';

import '../utils/saving_icon_helper.dart';

class CreateGoalBottomSheet extends ConsumerStatefulWidget {
  const CreateGoalBottomSheet({super.key});

  @override
  ConsumerState<CreateGoalBottomSheet> createState() => _CreateGoalBottomSheetState();
}

class _CreateGoalBottomSheetState extends ConsumerState<CreateGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  String _selectedIcon = 'home';
  String _selectedColor = '#00D4AA'; // Electric Teal

  final List<String> _colors = ['#00D4AA', '#F5A623', '#FF6B6B', '#111827', '#4A90E2', '#9B51E0'];

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final targetAmount = double.tryParse(_targetController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final currentAmount = double.tryParse(_initialBalanceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      
      final goal = SavingGoal(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        colorHex: _selectedColor,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: _selectedDate,
        createdAt: DateTime.now(),
      );

      ref.read(savingsProvider.notifier).addGoal(goal);
      Navigator.pop(context);
    }
  }

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Buat Goal Tabungan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Goal (misal: Dana Liburan)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Nominal (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _initialBalanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saldo Awal (Opsional)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 16),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline/Target Waktu'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              
              const SizedBox(height: 16),
              const Text('Pilih Kategori/Icon:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: SavingIconHelper.iconList.map((item) {
                  final id = item['id'] as String;
                  final iconData = item['icon'] as IconData;
                  final isSelected = _selectedIcon == id;
                  return ChoiceChip(
                    label: Icon(iconData, size: 24, color: isSelected ? AppColors.electricTeal : null),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedIcon = id);
                    },
                    backgroundColor: Colors.transparent,
                    selectedColor: AppColors.electricTeal.withOpacity(0.2),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              const Text('Pilih Warna:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _colorFromHex(color),
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                        boxShadow: [
                          if (isSelected) BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1),
                        ],
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                    ),
                  );
                }).toList(),
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
                  onPressed: _saveGoal,
                  child: const Text('Buat Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
