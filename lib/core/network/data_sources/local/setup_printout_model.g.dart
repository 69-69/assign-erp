// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_printout_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetupPrintOutAdapter extends TypeAdapter<SetupPrintOut> {
  @override
  final int typeId = 1;

  @override
  SetupPrintOut read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetupPrintOut(
      layout: fields[0] as String,
      footerColor: fields[1] as String,
      headerColor: fields[2] as String,
      paletteColor: (fields[3] as List).cast<String>(),
      companyLogo: fields[4] as String?,
      companyName: fields[5] as String?,
      companyEmail: fields[6] as String?,
      companyPhone: fields[7] as String?,
      companyAddress: fields[8] as String?,
      companyFax: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SetupPrintOut obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.layout)
      ..writeByte(1)
      ..write(obj.footerColor)
      ..writeByte(2)
      ..write(obj.headerColor)
      ..writeByte(3)
      ..write(obj.paletteColor)
      ..writeByte(4)
      ..write(obj.companyLogo)
      ..writeByte(5)
      ..write(obj.companyName)
      ..writeByte(6)
      ..write(obj.companyEmail)
      ..writeByte(7)
      ..write(obj.companyPhone)
      ..writeByte(8)
      ..write(obj.companyAddress)
      ..writeByte(9)
      ..write(obj.companyFax);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetupPrintOutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
