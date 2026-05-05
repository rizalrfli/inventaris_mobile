import 'package:hive/hive.dart';
import 'dart:math';

class SavingGoal {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final DateTime createdAt;

  SavingGoal({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.createdAt,
  });

  SavingGoal copyWith({
    String? id,
    String? name,
    String? icon,
    String? colorHex,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get progressPercent => (currentAmount / targetAmount * 100).clamp(0, 100);
  double get remainingAmount => max(0, targetAmount - currentAmount);
  int get remainingDays => deadline.difference(DateTime.now()).inDays;
  double get monthlyTargetDeposit => remainingAmount / max(1, remainingDays / 30);
  
  String get status {
    if (currentAmount >= targetAmount) return 'Completed';
    
    // Simple expected progress calculation
    final totalDays = max(1, deadline.difference(createdAt).inDays);
    final daysPassed = max(0, DateTime.now().difference(createdAt).inDays);
    final expectedProgress = daysPassed / totalDays;
    final actualProgress = currentAmount / targetAmount;
    
    if (actualProgress >= expectedProgress) {
      return 'On Track';
    } else {
      return 'Behind Schedule';
    }
  }
}

class SavingGoalAdapter extends TypeAdapter<SavingGoal> {
  @override
  final int typeId = 1;

  @override
  SavingGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingGoal(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      colorHex: fields[3] as String,
      targetAmount: fields[4] as double,
      currentAmount: fields[5] as double,
      deadline: fields[6] as DateTime,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavingGoal obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.targetAmount)
      ..writeByte(5)
      ..write(obj.currentAmount)
      ..writeByte(6)
      ..write(obj.deadline)
      ..writeByte(7)
      ..write(obj.createdAt);
  }
}
