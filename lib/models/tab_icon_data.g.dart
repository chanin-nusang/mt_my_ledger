// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_icon_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TabIconDataAdapter extends TypeAdapter<TabIconData> {
  @override
  final int typeId = 3;

  @override
  TabIconData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TabIconData(
      imagePath: fields[0] as String,
      selectedImagePath: fields[1] as String,
      isSelected: fields[2] as bool,
      index: fields[3] as int,
      animationController: fields[4] as AnimationController?,
    );
  }

  @override
  void write(BinaryWriter writer, TabIconData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.selectedImagePath)
      ..writeByte(2)
      ..write(obj.isSelected)
      ..writeByte(3)
      ..write(obj.index)
      ..writeByte(4)
      ..write(obj.animationController);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabIconDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
