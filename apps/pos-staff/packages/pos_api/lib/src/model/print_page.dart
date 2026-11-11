//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/print_page_label.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_page.g.dart';

/// PrintPage
///
/// Properties:
/// * [marginMm]
/// * [font]
/// * [fontSize]
/// * [lineSpacing]
/// * [copies]
/// * [label]
@BuiltValue()
abstract class PrintPage implements Built<PrintPage, PrintPageBuilder> {
  @BuiltValueField(wireName: r'margin_mm')
  num get marginMm;

  @BuiltValueField(wireName: r'font')
  PrintPageFontEnum get font;
  // enum fontEnum {  sans,  mono,  };

  @BuiltValueField(wireName: r'font_size')
  PrintPageFontSizeEnum get fontSize;
  // enum fontSizeEnum {  s,  m,  l,  };

  @BuiltValueField(wireName: r'line_spacing')
  num get lineSpacing;

  @BuiltValueField(wireName: r'copies')
  int? get copies;

  @BuiltValueField(wireName: r'label')
  PrintPageLabel? get label;

  PrintPage._();

  factory PrintPage([void updates(PrintPageBuilder b)]) = _$PrintPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintPage> get serializer => _$PrintPageSerializer();
}

class _$PrintPageSerializer implements PrimitiveSerializer<PrintPage> {
  @override
  final Iterable<Type> types = const [PrintPage, _$PrintPage];

  @override
  final String wireName = r'PrintPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'margin_mm';
    yield serializers.serialize(
      object.marginMm,
      specifiedType: const FullType(num),
    );
    yield r'font';
    yield serializers.serialize(
      object.font,
      specifiedType: const FullType(PrintPageFontEnum),
    );
    yield r'font_size';
    yield serializers.serialize(
      object.fontSize,
      specifiedType: const FullType(PrintPageFontSizeEnum),
    );
    yield r'line_spacing';
    yield serializers.serialize(
      object.lineSpacing,
      specifiedType: const FullType(num),
    );
    if (object.copies != null) {
      yield r'copies';
      yield serializers.serialize(
        object.copies,
        specifiedType: const FullType(int),
      );
    }
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType(PrintPageLabel),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintPage object, {
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
    required PrintPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'margin_mm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.marginMm = valueDes;
          break;
        case r'font':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintPageFontEnum),
          ) as PrintPageFontEnum;
          result.font = valueDes;
          break;
        case r'font_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintPageFontSizeEnum),
          ) as PrintPageFontSizeEnum;
          result.fontSize = valueDes;
          break;
        case r'line_spacing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lineSpacing = valueDes;
          break;
        case r'copies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.copies = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PrintPageLabel),
          ) as PrintPageLabel?;
          if (valueDes == null) continue;
          result.label.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintPageBuilder();
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

class PrintPageFontEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'sans')
  static const PrintPageFontEnum sans = _$printPageFontEnum_sans;
  @BuiltValueEnumConst(wireName: r'mono')
  static const PrintPageFontEnum mono = _$printPageFontEnum_mono;

  static Serializer<PrintPageFontEnum> get serializer =>
      _$printPageFontEnumSerializer;

  const PrintPageFontEnum._(String name) : super(name);

  static BuiltSet<PrintPageFontEnum> get values => _$printPageFontEnumValues;
  static PrintPageFontEnum valueOf(String name) =>
      _$printPageFontEnumValueOf(name);
}

class PrintPageFontSizeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r's')
  static const PrintPageFontSizeEnum s = _$printPageFontSizeEnum_s;
  @BuiltValueEnumConst(wireName: r'm')
  static const PrintPageFontSizeEnum m = _$printPageFontSizeEnum_m;
  @BuiltValueEnumConst(wireName: r'l')
  static const PrintPageFontSizeEnum l = _$printPageFontSizeEnum_l;

  static Serializer<PrintPageFontSizeEnum> get serializer =>
      _$printPageFontSizeEnumSerializer;

  const PrintPageFontSizeEnum._(String name) : super(name);

  static BuiltSet<PrintPageFontSizeEnum> get values =>
      _$printPageFontSizeEnumValues;
  static PrintPageFontSizeEnum valueOf(String name) =>
      _$printPageFontSizeEnumValueOf(name);
}
