import 'package:hive/hive.dart';

class SavingDeposit {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? note;

  SavingDeposit({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note,
  });
}

class SavingDepositAdapter extends TypeAdapter<SavingDeposit> {
  @override
  final int typeId = 2;

  @override
  SavingDeposit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingDeposit(
      id: fields[0] as String,
      goalId: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SavingDeposit obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.goalId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.note);
  }
}
