// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The branch stream of the paired device, shared by every screen. Null
/// while not paired. Credentials are read at each connect, so a staff
/// session that starts or ends applies on the next reconnect.

@ProviderFor(realtime)
const realtimeProvider = RealtimeProvider._();

/// The branch stream of the paired device, shared by every screen. Null
/// while not paired. Credentials are read at each connect, so a staff
/// session that starts or ends applies on the next reconnect.

final class RealtimeProvider
    extends
        $FunctionalProvider<
          ActionCableClient?,
          ActionCableClient?,
          ActionCableClient?
        >
    with $Provider<ActionCableClient?> {
  /// The branch stream of the paired device, shared by every screen. Null
  /// while not paired. Credentials are read at each connect, so a staff
  /// session that starts or ends applies on the next reconnect.
  const RealtimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realtimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realtimeHash();

  @$internal
  @override
  $ProviderElement<ActionCableClient?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ActionCableClient? create(Ref ref) {
    return realtime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActionCableClient? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActionCableClient?>(value),
    );
  }
}

String _$realtimeHash() => r'31a223318f705aed9b24e2755770cf0d82ea8df9';
