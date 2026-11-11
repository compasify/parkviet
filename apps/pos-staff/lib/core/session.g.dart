// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceStore)
const deviceStoreProvider = DeviceStoreProvider._();

final class DeviceStoreProvider
    extends $FunctionalProvider<DeviceStore, DeviceStore, DeviceStore>
    with $Provider<DeviceStore> {
  const DeviceStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceStoreHash();

  @$internal
  @override
  $ProviderElement<DeviceStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceStore create(Ref ref) {
    return deviceStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceStore>(value),
    );
  }
}

String _$deviceStoreHash() => r'1ca52d7babb14af36a8c42514c19be5a7fc87ba5';

@ProviderFor(credentials)
const credentialsProvider = CredentialsProvider._();

final class CredentialsProvider
    extends
        $FunctionalProvider<
          DeviceCredentials,
          DeviceCredentials,
          DeviceCredentials
        >
    with $Provider<DeviceCredentials> {
  const CredentialsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialsHash();

  @$internal
  @override
  $ProviderElement<DeviceCredentials> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceCredentials create(Ref ref) {
    return credentials(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceCredentials value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceCredentials>(value),
    );
  }
}

String _$credentialsHash() => r'ec7613383aa5eccd95cefc3c064da923fe32e911';

@ProviderFor(deviceDescriptor)
const deviceDescriptorProvider = DeviceDescriptorProvider._();

final class DeviceDescriptorProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceDescriptor>,
          DeviceDescriptor,
          FutureOr<DeviceDescriptor>
        >
    with $FutureModifier<DeviceDescriptor>, $FutureProvider<DeviceDescriptor> {
  const DeviceDescriptorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceDescriptorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceDescriptorHash();

  @$internal
  @override
  $FutureProviderElement<DeviceDescriptor> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceDescriptor> create(Ref ref) {
    return deviceDescriptor(ref);
  }
}

String _$deviceDescriptorHash() => r'9bdef2c7d9091c0256b9a3e3c9dd833dc0a5c6a2';

@ProviderFor(apiClientFactory)
const apiClientFactoryProvider = ApiClientFactoryProvider._();

final class ApiClientFactoryProvider
    extends
        $FunctionalProvider<
          ApiClientFactory,
          ApiClientFactory,
          ApiClientFactory
        >
    with $Provider<ApiClientFactory> {
  const ApiClientFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientFactoryHash();

  @$internal
  @override
  $ProviderElement<ApiClientFactory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClientFactory create(Ref ref) {
    return apiClientFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClientFactory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClientFactory>(value),
    );
  }
}

String _$apiClientFactoryHash() => r'a23f674f0898030deaf4f8d5991c1e49f56c52a0';

/// The client of the paired server. Only read it while paired.

@ProviderFor(apiClient)
const apiClientProvider = ApiClientProvider._();

/// The client of the paired server. Only read it while paired.

final class ApiClientProvider
    extends $FunctionalProvider<PosApiClient, PosApiClient, PosApiClient>
    with $Provider<PosApiClient> {
  /// The client of the paired server. Only read it while paired.
  const ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<PosApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PosApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PosApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PosApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'01dc4a35d4efb520ad57bb0afff30ff465baae00';

@ProviderFor(Session)
const sessionProvider = SessionProvider._();

final class SessionProvider
    extends $AsyncNotifierProvider<Session, AppSession> {
  const SessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  Session create() => Session();
}

String _$sessionHash() => r'4ee9102a80dff2768272766b46ea9c5191ba0599';

abstract class _$Session extends $AsyncNotifier<AppSession> {
  FutureOr<AppSession> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AppSession>, AppSession>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppSession>, AppSession>,
              AsyncValue<AppSession>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
