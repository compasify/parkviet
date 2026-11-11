//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_page_label.g.dart';

/// Label stock a label printer feeds (cup labels); absent for a roll.
///
/// Properties:
/// * [widthMm]
/// * [heightMm]
@BuiltValue()
abstract class PrintPageLabel
    implements Built<PrintPageLabel, PrintPageLabelBuilder> {
  @BuiltValueField(wireName: r'width_mm')
  int get widthMm;

  @BuiltValueField(wireName: r'height_mm')
  int get heightMm;

  PrintPageLabel._();

  factory PrintPageLabel([void updates(PrintPageLabelBuilder b)]) =
      _$PrintPageLabel;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintPageLabelBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintPageLabel> get serializer =>
      _$PrintPageLabelSerializer();
}

class _$PrintPageLabelSerializer
    implements PrimitiveSerializer<PrintPageLabel> {
  @override
  final Iterable<Type> types = const [PrintPageLabel, _$PrintPageLabel];

  @override
  final String wireName = r'PrintPageLabel';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintPageLabel object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'width_mm';
    yield serializers.serialize(
      object.widthMm,
      specifiedType: const FullType(int),
    );
    yield r'height_mm';
    yield serializers.serialize(
      object.heightMm,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintPageLabel object, {
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
    required PrintPageLabelBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'width_mm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.widthMm = valueDes;
          break;
        case r'height_mm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.heightMm = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintPageLabel deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintPageLabelBuilder();
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
