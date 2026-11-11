//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hardware_printer.g.dart';

/// HardwarePrinter
///
/// Properties:
/// * [id]
/// * [name]
/// * [connection]
/// * [roles]
/// * [viaPrintStation]
/// * [lastJobStatus] - queued, claimed, printed, failed or canceled; null before the first job.
/// * [lastJobKind]
/// * [lastJobAt]
/// * [lastError]
@BuiltValue()
abstract class HardwarePrinter
    implements Built<HardwarePrinter, HardwarePrinterBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'connection')
  String get connection;

  @BuiltValueField(wireName: r'roles')
  BuiltList<String> get roles;

  @BuiltValueField(wireName: r'via_print_station')
  bool get viaPrintStation;

  /// queued, claimed, printed, failed or canceled; null before the first job.
  @BuiltValueField(wireName: r'last_job_status')
  String get lastJobStatus;

  @BuiltValueField(wireName: r'last_job_kind')
  String get lastJobKind;

  @BuiltValueField(wireName: r'last_job_at')
  DateTime get lastJobAt;

  @BuiltValueField(wireName: r'last_error')
  String get lastError;

  HardwarePrinter._();

  factory HardwarePrinter([void updates(HardwarePrinterBuilder b)]) =
      _$HardwarePrinter;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HardwarePrinterBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HardwarePrinter> get serializer =>
      _$HardwarePrinterSerializer();
}

class _$HardwarePrinterSerializer
    implements PrimitiveSerializer<HardwarePrinter> {
  @override
  final Iterable<Type> types = const [HardwarePrinter, _$HardwarePrinter];

  @override
  final String wireName = r'HardwarePrinter';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HardwarePrinter object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'connection';
    yield serializers.serialize(
      object.connection,
      specifiedType: const FullType(String),
    );
    yield r'roles';
    yield serializers.serialize(
      object.roles,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'via_print_station';
    yield serializers.serialize(
      object.viaPrintStation,
      specifiedType: const FullType(bool),
    );
    yield r'last_job_status';
    yield serializers.serialize(
      object.lastJobStatus,
      specifiedType: const FullType(String),
    );
    yield r'last_job_kind';
    yield serializers.serialize(
      object.lastJobKind,
      specifiedType: const FullType(String),
    );
    yield r'last_job_at';
    yield serializers.serialize(
      object.lastJobAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'last_error';
    yield serializers.serialize(
      object.lastError,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HardwarePrinter object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HardwarePrinterBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'connection':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.connection = valueDes;
          break;
        case r'roles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.roles.replace(valueDes);
          break;
        case r'via_print_station':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.viaPrintStation = valueDes;
          break;
        case r'last_job_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lastJobStatus = valueDes;
          break;
        case r'last_job_kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lastJobKind = valueDes;
          break;
        case r'last_job_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastJobAt = valueDes;
          break;
        case r'last_error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lastError = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HardwarePrinter deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HardwarePrinterBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
