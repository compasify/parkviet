//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_window.g.dart';

/// MealWindow
///
/// Properties:
/// * [key]
/// * [from] - Local time HH:MM
/// * [to] - Local time HH:MM; before `from` when the window crosses midnight
/// * [limit]
@BuiltValue()
abstract class MealWindow implements Built<MealWindow, MealWindowBuilder> {
  @BuiltValueField(wireName: r'key')
  String get key;

  /// Local time HH:MM
  @BuiltValueField(wireName: r'from')
  String get from;

  /// Local time HH:MM; before `from` when the window crosses midnight
  @BuiltValueField(wireName: r'to')
  String get to;

  @BuiltValueField(wireName: r'limit')
  int? get limit;

  MealWindow._();

  factory MealWindow([void updates(MealWindowBuilder b)]) = _$MealWindow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealWindowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealWindow> get serializer => _$MealWindowSerializer();
}

class _$MealWindowSerializer implements PrimitiveSerializer<MealWindow> {
  @override
  final Iterable<Type> types = const [MealWindow, _$MealWindow];

  @override
  final String wireName = r'MealWindow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealWindow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'from';
    yield serializers.serialize(
      object.from,
      specifiedType: const FullType(String),
    );
    yield r'to';
    yield serializers.serialize(
      object.to,
      specifiedType: const FullType(String),
    );
    if (object.limit != null) {
      yield r'limit';
      yield serializers.serialize(
        object.limit,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MealWindow object, {
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
    required MealWindowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.from = valueDes;
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.to = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.limit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MealWindow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealWindowBuilder();
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
