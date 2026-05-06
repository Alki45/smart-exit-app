// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_material.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseMaterialAdapter extends TypeAdapter<CourseMaterial> {
  @override
  final int typeId = 5;

  @override
  CourseMaterial read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseMaterial(
      id: fields[0] as String,
      courseId: fields[1] as String,
      fileName: fields[2] as String,
      rawText: fields[3] as String,
      analysis: (fields[4] as Map).cast<String, dynamic>(),
      uploadedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CourseMaterial obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseId)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.rawText)
      ..writeByte(4)
      ..write(obj.analysis)
      ..writeByte(5)
      ..write(obj.uploadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseMaterialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
