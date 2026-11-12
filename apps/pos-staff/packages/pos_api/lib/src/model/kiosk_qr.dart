//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_qr.g.dart';

/// KioskQr
///
/// Properties:
/// * [qrUrl]
/// * [bankName]
/// * [accountNumber]
/// * [accountName]
/// * [transferNote]
@BuiltValue()
abstract class KioskQr implements Built<KioskQr, KioskQrBuilder> {
  @BuiltValueField(wireName: r'qr_url')
  String get qrUrl;

  @BuiltValueField(wireName: r'bank_name')
  String? get bankName;

  @BuiltValueField(wireName: r'account_number')
  String get accountNumber;

  @BuiltValueField(wireName: r'account_name')
  String? get accountName;

  @BuiltValueField(wireName: r'transfer_note')
  String get transferNote;

  KioskQr._();

  factory KioskQr([void updates(KioskQrBuilder b)]) = _$KioskQr;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskQrBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskQr> get serializer => _$KioskQrSerializer();
}

class _$KioskQrSerializer implements PrimitiveSerializer<KioskQr> {
  @override
  final Iterable<Type> types = const [KioskQr, _$KioskQr];

  @override
  final String wireName = r'KioskQr';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskQr object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'qr_url';
    yield serializers.serialize(
      object.qrUrl,
      specifiedType: const FullType(String),
    );
    yield r'bank_name';
    yield object.bankName == null
        ? null
        : serializers.serialize(
            object.bankName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'account_number';
    yield serializers.serialize(
      object.accountNumber,
      specifiedType: const FullType(String),
    );
    yield r'account_name';
    yield object.accountName == null
        ? null
        : serializers.serialize(
            object.accountName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'transfer_note';
    yield serializers.serialize(
      object.transferNote,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskQr object, {
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
    required KioskQrBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'qr_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.qrUrl = valueDes;
          break;
        case r'bank_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bankName = valueDes;
          break;
        case r'account_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accountNumber = valueDes;
          break;
        case r'account_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.accountName = valueDes;
          break;
        case r'transfer_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.transferNote = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskQr deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskQrBuilder();
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
