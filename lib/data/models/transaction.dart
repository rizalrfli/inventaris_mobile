import 'package:hive/hive.dart';

class Transaction {
  final String id;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String? description;
  final DateTime date;
  final String paymentMethod;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.date,
    required this.paymentMethod,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      amount: fields[1] as double,
      type: fields[2] as String,
      category: fields[3] as String,
      description: fields[4] as String?,
      date: fields[5] as DateTime,
      paymentMethod: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.paymentMethod);
  }
}
