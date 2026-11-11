// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The names at the branch, for the picker.

@ProviderFor(branchStaff)
const branchStaffProvider = BranchStaffProvider._();

/// The names at the branch, for the picker.

final class BranchStaffProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeviceStaffMember>>,
          List<DeviceStaffMember>,
          FutureOr<List<DeviceStaffMember>>
        >
    with
        $FutureModifier<List<DeviceStaffMember>>,
        $FutureProvider<List<DeviceStaffMember>> {
  /// The names at the branch, for the picker.
  const BranchStaffProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchStaffProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchStaffHash();

  @$internal
  @override
  $FutureProviderElement<List<DeviceStaffMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DeviceStaffMember>> create(Ref ref) {
    return branchStaff(ref);
  }
}

String _$branchStaffHash() => r'e001983ca37c07f132d3a7414d3cbac86db46692';

/// The person signed in on this device, or null. Signs out after
/// [AppConfig.staffIdleTimeout] without a touch.

@ProviderFor(StaffSessionController)
const staffSessionControllerProvider = StaffSessionControllerProvider._();

/// The person signed in on this device, or null. Signs out after
/// [AppConfig.staffIdleTimeout] without a touch.
final class StaffSessionControllerProvider
    extends $NotifierProvider<StaffSessionController, StaffSession?> {
  /// The person signed in on this device, or null. Signs out after
  /// [AppConfig.staffIdleTimeout] without a touch.
  const StaffSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'staffSessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$staffSessionControllerHash();

  @$internal
  @override
  StaffSessionController create() => StaffSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StaffSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StaffSession?>(value),
    );
  }
}

String _$staffSessionControllerHash() =>
    r'09e01f61e37d10b550374f15e08b71bbe49dfb60';

/// The person signed in on this device, or null. Signs out after
/// [AppConfig.staffIdleTimeout] without a touch.

abstract class _$StaffSessionController extends $Notifier<StaffSession?> {
  StaffSession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<StaffSession?, StaffSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StaffSession?, StaffSession?>,
              StaffSession?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
