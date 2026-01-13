// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScreeningRecordAdapter extends TypeAdapter<ScreeningRecord> {
  @override
  final int typeId = 0;

  @override
  ScreeningRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScreeningRecord(
      id: fields[0] as String,
      score: fields[1] as double,
      riskLevel: fields[2] as String,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ScreeningRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.riskLevel)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreeningRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
