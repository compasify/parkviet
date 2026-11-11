// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'print_loop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrintLogEntry implements DiagnosticableTreeMixin {

/// Null for a local test print, which the server does not know about.
 String? get jobId; String get kind; String get printerName; bool get printed; String? get error; DateTime get at;
/// Create a copy of PrintLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrintLogEntryCopyWith<PrintLogEntry> get copyWith => _$PrintLogEntryCopyWithImpl<PrintLogEntry>(this as PrintLogEntry, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PrintLogEntry'))
    ..add(DiagnosticsProperty('jobId', jobId))..add(DiagnosticsProperty('kind', kind))..add(DiagnosticsProperty('printerName', printerName))..add(DiagnosticsProperty('printed', printed))..add(DiagnosticsProperty('error', error))..add(DiagnosticsProperty('at', at));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrintLogEntry&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.printerName, printerName) || other.printerName == printerName)&&(identical(other.printed, printed) || other.printed == printed)&&(identical(other.error, error) || other.error == error)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode => Object.hash(runtimeType,jobId,kind,printerName,printed,error,at);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PrintLogEntry(jobId: $jobId, kind: $kind, printerName: $printerName, printed: $printed, error: $error, at: $at)';
}


}

/// @nodoc
abstract mixin class $PrintLogEntryCopyWith<$Res>  {
  factory $PrintLogEntryCopyWith(PrintLogEntry value, $Res Function(PrintLogEntry) _then) = _$PrintLogEntryCopyWithImpl;
@useResult
$Res call({
 String? jobId, String kind, String printerName, bool printed, String? error, DateTime at
});




}
/// @nodoc
class _$PrintLogEntryCopyWithImpl<$Res>
    implements $PrintLogEntryCopyWith<$Res> {
  _$PrintLogEntryCopyWithImpl(this._self, this._then);

  final PrintLogEntry _self;
  final $Res Function(PrintLogEntry) _then;

/// Create a copy of PrintLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = freezed,Object? kind = null,Object? printerName = null,Object? printed = null,Object? error = freezed,Object? at = null,}) {
  return _then(_self.copyWith(
jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,printerName: null == printerName ? _self.printerName : printerName // ignore: cast_nullable_to_non_nullable
as String,printed: null == printed ? _self.printed : printed // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PrintLogEntry].
extension PrintLogEntryPatterns on PrintLogEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrintLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrintLogEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrintLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _PrintLogEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrintLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PrintLogEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? jobId,  String kind,  String printerName,  bool printed,  String? error,  DateTime at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrintLogEntry() when $default != null:
return $default(_that.jobId,_that.kind,_that.printerName,_that.printed,_that.error,_that.at);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? jobId,  String kind,  String printerName,  bool printed,  String? error,  DateTime at)  $default,) {final _that = this;
switch (_that) {
case _PrintLogEntry():
return $default(_that.jobId,_that.kind,_that.printerName,_that.printed,_that.error,_that.at);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? jobId,  String kind,  String printerName,  bool printed,  String? error,  DateTime at)?  $default,) {final _that = this;
switch (_that) {
case _PrintLogEntry() when $default != null:
return $default(_that.jobId,_that.kind,_that.printerName,_that.printed,_that.error,_that.at);case _:
  return null;

}
}

}

/// @nodoc


class _PrintLogEntry with DiagnosticableTreeMixin implements PrintLogEntry {
  const _PrintLogEntry({this.jobId, required this.kind, required this.printerName, required this.printed, this.error, required this.at});
  

/// Null for a local test print, which the server does not know about.
@override final  String? jobId;
@override final  String kind;
@override final  String printerName;
@override final  bool printed;
@override final  String? error;
@override final  DateTime at;

/// Create a copy of PrintLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrintLogEntryCopyWith<_PrintLogEntry> get copyWith => __$PrintLogEntryCopyWithImpl<_PrintLogEntry>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PrintLogEntry'))
    ..add(DiagnosticsProperty('jobId', jobId))..add(DiagnosticsProperty('kind', kind))..add(DiagnosticsProperty('printerName', printerName))..add(DiagnosticsProperty('printed', printed))..add(DiagnosticsProperty('error', error))..add(DiagnosticsProperty('at', at));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrintLogEntry&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.printerName, printerName) || other.printerName == printerName)&&(identical(other.printed, printed) || other.printed == printed)&&(identical(other.error, error) || other.error == error)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode => Object.hash(runtimeType,jobId,kind,printerName,printed,error,at);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PrintLogEntry(jobId: $jobId, kind: $kind, printerName: $printerName, printed: $printed, error: $error, at: $at)';
}


}

/// @nodoc
abstract mixin class _$PrintLogEntryCopyWith<$Res> implements $PrintLogEntryCopyWith<$Res> {
  factory _$PrintLogEntryCopyWith(_PrintLogEntry value, $Res Function(_PrintLogEntry) _then) = __$PrintLogEntryCopyWithImpl;
@override @useResult
$Res call({
 String? jobId, String kind, String printerName, bool printed, String? error, DateTime at
});




}
/// @nodoc
class __$PrintLogEntryCopyWithImpl<$Res>
    implements _$PrintLogEntryCopyWith<$Res> {
  __$PrintLogEntryCopyWithImpl(this._self, this._then);

  final _PrintLogEntry _self;
  final $Res Function(_PrintLogEntry) _then;

/// Create a copy of PrintLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = freezed,Object? kind = null,Object? printerName = null,Object? printed = null,Object? error = freezed,Object? at = null,}) {
  return _then(_PrintLogEntry(
jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,printerName: null == printerName ? _self.printerName : printerName // ignore: cast_nullable_to_non_nullable
as String,printed: null == printed ? _self.printed : printed // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$PrintStationState implements DiagnosticableTreeMixin {

 bool get running; bool get busy;/// The last time the server could not be reached, cleared on success.
 AppFailure? get serverFailure; Map<String, PrinterProfile> get printers; List<PrintLogEntry> get recent;
/// Create a copy of PrintStationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrintStationStateCopyWith<PrintStationState> get copyWith => _$PrintStationStateCopyWithImpl<PrintStationState>(this as PrintStationState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PrintStationState'))
    ..add(DiagnosticsProperty('running', running))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('serverFailure', serverFailure))..add(DiagnosticsProperty('printers', printers))..add(DiagnosticsProperty('recent', recent));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrintStationState&&(identical(other.running, running) || other.running == running)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.serverFailure, serverFailure) || other.serverFailure == serverFailure)&&const DeepCollectionEquality().equals(other.printers, printers)&&const DeepCollectionEquality().equals(other.recent, recent));
}


@override
int get hashCode => Object.hash(runtimeType,running,busy,serverFailure,const DeepCollectionEquality().hash(printers),const DeepCollectionEquality().hash(recent));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PrintStationState(running: $running, busy: $busy, serverFailure: $serverFailure, printers: $printers, recent: $recent)';
}


}

/// @nodoc
abstract mixin class $PrintStationStateCopyWith<$Res>  {
  factory $PrintStationStateCopyWith(PrintStationState value, $Res Function(PrintStationState) _then) = _$PrintStationStateCopyWithImpl;
@useResult
$Res call({
 bool running, bool busy, AppFailure? serverFailure, Map<String, PrinterProfile> printers, List<PrintLogEntry> recent
});


$AppFailureCopyWith<$Res>? get serverFailure;

}
/// @nodoc
class _$PrintStationStateCopyWithImpl<$Res>
    implements $PrintStationStateCopyWith<$Res> {
  _$PrintStationStateCopyWithImpl(this._self, this._then);

  final PrintStationState _self;
  final $Res Function(PrintStationState) _then;

/// Create a copy of PrintStationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? running = null,Object? busy = null,Object? serverFailure = freezed,Object? printers = null,Object? recent = null,}) {
  return _then(_self.copyWith(
running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,serverFailure: freezed == serverFailure ? _self.serverFailure : serverFailure // ignore: cast_nullable_to_non_nullable
as AppFailure?,printers: null == printers ? _self.printers : printers // ignore: cast_nullable_to_non_nullable
as Map<String, PrinterProfile>,recent: null == recent ? _self.recent : recent // ignore: cast_nullable_to_non_nullable
as List<PrintLogEntry>,
  ));
}
/// Create a copy of PrintStationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppFailureCopyWith<$Res>? get serverFailure {
    if (_self.serverFailure == null) {
    return null;
  }

  return $AppFailureCopyWith<$Res>(_self.serverFailure!, (value) {
    return _then(_self.copyWith(serverFailure: value));
  });
}
}


/// Adds pattern-matching-related methods to [PrintStationState].
extension PrintStationStatePatterns on PrintStationState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrintStationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrintStationState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrintStationState value)  $default,){
final _that = this;
switch (_that) {
case _PrintStationState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrintStationState value)?  $default,){
final _that = this;
switch (_that) {
case _PrintStationState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool running,  bool busy,  AppFailure? serverFailure,  Map<String, PrinterProfile> printers,  List<PrintLogEntry> recent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrintStationState() when $default != null:
return $default(_that.running,_that.busy,_that.serverFailure,_that.printers,_that.recent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool running,  bool busy,  AppFailure? serverFailure,  Map<String, PrinterProfile> printers,  List<PrintLogEntry> recent)  $default,) {final _that = this;
switch (_that) {
case _PrintStationState():
return $default(_that.running,_that.busy,_that.serverFailure,_that.printers,_that.recent);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool running,  bool busy,  AppFailure? serverFailure,  Map<String, PrinterProfile> printers,  List<PrintLogEntry> recent)?  $default,) {final _that = this;
switch (_that) {
case _PrintStationState() when $default != null:
return $default(_that.running,_that.busy,_that.serverFailure,_that.printers,_that.recent);case _:
  return null;

}
}

}

/// @nodoc


class _PrintStationState with DiagnosticableTreeMixin implements PrintStationState {
  const _PrintStationState({this.running = false, this.busy = false, this.serverFailure, final  Map<String, PrinterProfile> printers = const {}, final  List<PrintLogEntry> recent = const []}): _printers = printers,_recent = recent;
  

@override@JsonKey() final  bool running;
@override@JsonKey() final  bool busy;
/// The last time the server could not be reached, cleared on success.
@override final  AppFailure? serverFailure;
 final  Map<String, PrinterProfile> _printers;
@override@JsonKey() Map<String, PrinterProfile> get printers {
  if (_printers is EqualUnmodifiableMapView) return _printers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_printers);
}

 final  List<PrintLogEntry> _recent;
@override@JsonKey() List<PrintLogEntry> get recent {
  if (_recent is EqualUnmodifiableListView) return _recent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recent);
}


/// Create a copy of PrintStationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrintStationStateCopyWith<_PrintStationState> get copyWith => __$PrintStationStateCopyWithImpl<_PrintStationState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PrintStationState'))
    ..add(DiagnosticsProperty('running', running))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('serverFailure', serverFailure))..add(DiagnosticsProperty('printers', printers))..add(DiagnosticsProperty('recent', recent));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrintStationState&&(identical(other.running, running) || other.running == running)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.serverFailure, serverFailure) || other.serverFailure == serverFailure)&&const DeepCollectionEquality().equals(other._printers, _printers)&&const DeepCollectionEquality().equals(other._recent, _recent));
}


@override
int get hashCode => Object.hash(runtimeType,running,busy,serverFailure,const DeepCollectionEquality().hash(_printers),const DeepCollectionEquality().hash(_recent));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PrintStationState(running: $running, busy: $busy, serverFailure: $serverFailure, printers: $printers, recent: $recent)';
}


}

/// @nodoc
abstract mixin class _$PrintStationStateCopyWith<$Res> implements $PrintStationStateCopyWith<$Res> {
  factory _$PrintStationStateCopyWith(_PrintStationState value, $Res Function(_PrintStationState) _then) = __$PrintStationStateCopyWithImpl;
@override @useResult
$Res call({
 bool running, bool busy, AppFailure? serverFailure, Map<String, PrinterProfile> printers, List<PrintLogEntry> recent
});


@override $AppFailureCopyWith<$Res>? get serverFailure;

}
/// @nodoc
class __$PrintStationStateCopyWithImpl<$Res>
    implements _$PrintStationStateCopyWith<$Res> {
  __$PrintStationStateCopyWithImpl(this._self, this._then);

  final _PrintStationState _self;
  final $Res Function(_PrintStationState) _then;

/// Create a copy of PrintStationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? running = null,Object? busy = null,Object? serverFailure = freezed,Object? printers = null,Object? recent = null,}) {
  return _then(_PrintStationState(
running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,serverFailure: freezed == serverFailure ? _self.serverFailure : serverFailure // ignore: cast_nullable_to_non_nullable
as AppFailure?,printers: null == printers ? _self._printers : printers // ignore: cast_nullable_to_non_nullable
as Map<String, PrinterProfile>,recent: null == recent ? _self._recent : recent // ignore: cast_nullable_to_non_nullable
as List<PrintLogEntry>,
  ));
}

/// Create a copy of PrintStationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppFailureCopyWith<$Res>? get serverFailure {
    if (_self.serverFailure == null) {
    return null;
  }

  return $AppFailureCopyWith<$Res>(_self.serverFailure!, (value) {
    return _then(_self.copyWith(serverFailure: value));
  });
}
}

// dart format on
