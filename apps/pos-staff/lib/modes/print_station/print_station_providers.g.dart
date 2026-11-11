// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_station_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(documentRenderer)
const documentRendererProvider = DocumentRendererProvider._();

final class DocumentRendererProvider
    extends
        $FunctionalProvider<
          AsyncValue<DocumentRenderer>,
          DocumentRenderer,
          FutureOr<DocumentRenderer>
        >
    with $FutureModifier<DocumentRenderer>, $FutureProvider<DocumentRenderer> {
  const DocumentRendererProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentRendererProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentRendererHash();

  @$internal
  @override
  $FutureProviderElement<DocumentRenderer> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DocumentRenderer> create(Ref ref) {
    return documentRenderer(ref);
  }
}

String _$documentRendererHash() => r'557a9b43e2f5d018268c63eca56f8cfe455931b2';

@ProviderFor(stationKeepAwake)
const stationKeepAwakeProvider = StationKeepAwakeProvider._();

final class StationKeepAwakeProvider
    extends
        $FunctionalProvider<
          StationKeepAwake,
          StationKeepAwake,
          StationKeepAwake
        >
    with $Provider<StationKeepAwake> {
  const StationKeepAwakeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stationKeepAwakeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stationKeepAwakeHash();

  @$internal
  @override
  $ProviderElement<StationKeepAwake> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StationKeepAwake create(Ref ref) {
    return stationKeepAwake(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StationKeepAwake value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StationKeepAwake>(value),
    );
  }
}

String _$stationKeepAwakeHash() => r'bae3465b5af14410f713234fd2897d1c9c612158';

/// The report the server has not taken yet, kept across rebuilds of
/// [printLoop] (a new session or realtime connection builds a new loop).

@ProviderFor(pendingPrintReport)
const pendingPrintReportProvider = PendingPrintReportProvider._();

/// The report the server has not taken yet, kept across rebuilds of
/// [printLoop] (a new session or realtime connection builds a new loop).

final class PendingPrintReportProvider
    extends
        $FunctionalProvider<
          PendingPrintReport,
          PendingPrintReport,
          PendingPrintReport
        >
    with $Provider<PendingPrintReport> {
  /// The report the server has not taken yet, kept across rebuilds of
  /// [printLoop] (a new session or realtime connection builds a new loop).
  const PendingPrintReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingPrintReportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingPrintReportHash();

  @$internal
  @override
  $ProviderElement<PendingPrintReport> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PendingPrintReport create(Ref ref) {
    return pendingPrintReport(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingPrintReport value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingPrintReport>(value),
    );
  }
}

String _$pendingPrintReportHash() =>
    r'181f92cf5cdbc6ec5bf060ce6abc3d1215d23779';

/// The running loop of this print station, alive while its screen is.

@ProviderFor(printLoop)
const printLoopProvider = PrintLoopProvider._();

/// The running loop of this print station, alive while its screen is.

final class PrintLoopProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrintLoop>,
          PrintLoop,
          FutureOr<PrintLoop>
        >
    with $FutureModifier<PrintLoop>, $FutureProvider<PrintLoop> {
  /// The running loop of this print station, alive while its screen is.
  const PrintLoopProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printLoopProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printLoopHash();

  @$internal
  @override
  $FutureProviderElement<PrintLoop> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PrintLoop> create(Ref ref) {
    return printLoop(ref);
  }
}

String _$printLoopHash() => r'6ff7b50d244f2f90dea5f516a682235b04f9d29e';
