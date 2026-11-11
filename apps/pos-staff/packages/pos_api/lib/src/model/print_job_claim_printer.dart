//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_job_claim_printer.g.dart';

/// PrintJobClaimPrinter
///
/// Properties:
/// * [id]
/// * [name]
/// * [connection]
/// * [address]
/// * [bluetoothId]
/// * [paper]
/// * [commandLanguage]
/// * [settings]
@BuiltValue()
abstract class PrintJobClaimPrinter
    implements Built<PrintJobClaimPrinter, PrintJobClaimPrinterBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'connection')
  String get connection;

  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'bluetooth_id')
  String? get bluetoothId;

  @BuiltValueField(wireName: r'paper')
  String get paper;

  @BuiltValueField(wireName: r'command_language')
  String get commandLanguage;

  @BuiltValueField(wireName: r'settings')
  JsonObject get settings;

  PrintJobClaimPrinter._();

  factory PrintJobClaimPrinter([void updates(PrintJobClaimPrinterBuilder b)]) =
      _$PrintJobClaimPrinter;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintJobClaimPrinterBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintJobClaimPrinter> get serializer =>
      _$PrintJobClaimPrinterSerializer();
}

class _$PrintJobClaimPrinterSerializer
    implements PrimitiveSerializer<PrintJobClaimPrinter> {
  @override
  final Iterable<Type> types = const [
    PrintJobClaimPrinter,
    _$PrintJobClaimPrinter
  ];

  @override
  final String wireName = r'PrintJobClaimPrinter';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintJobClaimPrinter object, {
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
    yield r'address';
    yield object.address == null
        ? null
        : serializers.serialize(
            object.address,
            specifiedType: const FullType.nullable(String),
          );
    yield r'bluetooth_id';
    yield object.bluetoothId == null
        ? null
        : serializers.serialize(
            object.bluetoothId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'paper';
    yield serializers.serialize(
      object.paper,
      specifiedType: const FullType(String),
    );
    yield r'command_language';
    yield serializers.serialize(
      object.commandLanguage,
      specifiedType: const FullType(String),
    );
    yield r'settings';
    yield serializers.serialize(
      object.settings,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintJobClaimPrinter object, {
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
    required PrintJobClaimPrinterBuilder result,
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
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.address = valueDes;
          break;
        case r'bluetooth_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bluetoothId = valueDes;
          break;
        case r'paper':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.paper = valueDes;
          break;
        case r'command_language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.commandLanguage = valueDes;
          break;
        case r'settings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.settings = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintJobClaimPrinter deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintJobClaimPrinterBuilder();
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
