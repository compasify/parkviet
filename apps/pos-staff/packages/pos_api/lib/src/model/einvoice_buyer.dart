//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_buyer.g.dart';

/// Who the invoice is for. Empty is a sale to a consumer, printed with the store's consumer label. A tax code needs the registered name and address. `label` is set by the server when the invoice issues to a consumer.
///
/// Properties:
/// * [taxCode]
/// * [name]
/// * [address]
/// * [personalId]
/// * [phone]
/// * [passportNo]
/// * [nationality]
/// * [email]
/// * [buyerNote]
/// * [label]
@BuiltValue()
abstract class EinvoiceBuyer
    implements Built<EinvoiceBuyer, EinvoiceBuyerBuilder> {
  @BuiltValueField(wireName: r'tax_code')
  String? get taxCode;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'personal_id')
  String? get personalId;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'passport_no')
  String? get passportNo;

  @BuiltValueField(wireName: r'nationality')
  String? get nationality;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'buyer_note')
  String? get buyerNote;

  @BuiltValueField(wireName: r'label')
  String? get label;

  EinvoiceBuyer._();

  factory EinvoiceBuyer([void updates(EinvoiceBuyerBuilder b)]) =
      _$EinvoiceBuyer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceBuyerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceBuyer> get serializer =>
      _$EinvoiceBuyerSerializer();
}

class _$EinvoiceBuyerSerializer implements PrimitiveSerializer<EinvoiceBuyer> {
  @override
  final Iterable<Type> types = const [EinvoiceBuyer, _$EinvoiceBuyer];

  @override
  final String wireName = r'EinvoiceBuyer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceBuyer object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.taxCode != null) {
      yield r'tax_code';
      yield serializers.serialize(
        object.taxCode,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType(String),
      );
    }
    if (object.personalId != null) {
      yield r'personal_id';
      yield serializers.serialize(
        object.personalId,
        specifiedType: const FullType(String),
      );
    }
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType(String),
      );
    }
    if (object.passportNo != null) {
      yield r'passport_no';
      yield serializers.serialize(
        object.passportNo,
        specifiedType: const FullType(String),
      );
    }
    if (object.nationality != null) {
      yield r'nationality';
      yield serializers.serialize(
        object.nationality,
        specifiedType: const FullType(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    if (object.buyerNote != null) {
      yield r'buyer_note';
      yield serializers.serialize(
        object.buyerNote,
        specifiedType: const FullType(String),
      );
    }
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceBuyer object, {
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
    required EinvoiceBuyerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tax_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.taxCode = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.address = valueDes;
          break;
        case r'personal_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.personalId = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'passport_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.passportNo = valueDes;
          break;
        case r'nationality':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nationality = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'buyer_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.buyerNote = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceBuyer deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceBuyerBuilder();
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
