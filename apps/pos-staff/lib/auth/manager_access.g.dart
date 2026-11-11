// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manager_access.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether a manager PIN opened device management. Closed again when the
/// management screen is left.

@ProviderFor(ManagerAccess)
const managerAccessProvider = ManagerAccessProvider._();

/// Whether a manager PIN opened device management. Closed again when the
/// management screen is left.
final class ManagerAccessProvider
    extends $NotifierProvider<ManagerAccess, bool> {
  /// Whether a manager PIN opened device management. Closed again when the
  /// management screen is left.
  const ManagerAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'managerAccessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$managerAccessHash();

  @$internal
  @override
  ManagerAccess create() => ManagerAccess();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$managerAccessHash() => r'51ff89b13cff4d608546c0039325dd1a3774b060';

/// Whether a manager PIN opened device management. Closed again when the
/// management screen is left.

abstract class _$ManagerAccess extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
