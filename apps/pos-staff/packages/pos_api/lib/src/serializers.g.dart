// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(Approval.serializer)
      ..add(ApprovalRevision.serializer)
      ..add(CatalogItem.serializer)
      ..add(Context.serializer)
      ..add(ContextAdministration.serializer)
      ..add(ContextStaff.serializer)
      ..add(ContextStore.serializer)
      ..add(Device.serializer)
      ..add(DeviceModeEnum.serializer)
      ..add(DevicePairResult.serializer)
      ..add(DevicePairing.serializer)
      ..add(DevicePairingQr.serializer)
      ..add(DeviceSession.serializer)
      ..add(DeviceSessionBranch.serializer)
      ..add(DeviceSessionStaff.serializer)
      ..add(DeviceStaffMember.serializer)
      ..add(DeviceStaffSignIn.serializer)
      ..add(DeviceStatusEnum.serializer)
      ..add(ErrorResponse.serializer)
      ..add(ErrorResponseError.serializer)
      ..add(ErrorResponseErrorDetails.serializer)
      ..add(PosApprovalCreate201Response.serializer)
      ..add(PosCatalog200Response.serializer)
      ..add(PosDeviceMe200Response.serializer)
      ..add(PosDevicePair201Response.serializer)
      ..add(PosDevicePairRequest.serializer)
      ..add(PosDevicePairRequestPlatformEnum.serializer)
      ..add(PosDevicePrintClaim200Response.serializer)
      ..add(PosDevicePrintReportRequest.serializer)
      ..add(PosDevicePrintReportRequestStatusEnum.serializer)
      ..add(PosDeviceStaff200Response.serializer)
      ..add(PosDeviceStaffSignIn201Response.serializer)
      ..add(PosDeviceStaffSignInRequest.serializer)
      ..add(PosPrintJobCancel200Response.serializer)
      ..add(PosPrintJobCreate201Response.serializer)
      ..add(PosPrintJobCreateRequest.serializer)
      ..add(PosPrintJobCreateRequestKindEnum.serializer)
      ..add(PosPrintJobReprintRequest.serializer)
      ..add(PosPrintJobs200Response.serializer)
      ..add(PosPrinterCreate201Response.serializer)
      ..add(PosPrinterCreateRequest.serializer)
      ..add(PosPrinterCreateRequestCommandLanguageEnum.serializer)
      ..add(PosPrinterCreateRequestConnectionEnum.serializer)
      ..add(PosPrinterCreateRequestPaperEnum.serializer)
      ..add(PosPrinterCreateRequestStatusEnum.serializer)
      ..add(PosPrinterDelete200Response.serializer)
      ..add(PosPrinterDelete200ResponseData.serializer)
      ..add(PosPrinterStations200Response.serializer)
      ..add(PosPrinterStations200ResponseDataInner.serializer)
      ..add(PosPrinterTest200Response.serializer)
      ..add(PosPrinterTest200ResponseData.serializer)
      ..add(PosPrinterUpdateRequest.serializer)
      ..add(PosPrinterUpdateRequestCommandLanguageEnum.serializer)
      ..add(PosPrinterUpdateRequestConnectionEnum.serializer)
      ..add(PosPrinterUpdateRequestPaperEnum.serializer)
      ..add(PosPrinterUpdateRequestStatusEnum.serializer)
      ..add(PosPrinters200Response.serializer)
      ..add(PosReceiptPrintVoid200Response.serializer)
      ..add(PosReceiptPrintVoid200ResponseData.serializer)
      ..add(PosReceiptPrintVoidRequest.serializer)
      ..add(PosReceiptPrintVoidRequestReasonEnum.serializer)
      ..add(PosSystemStatus200Response.serializer)
      ..add(PosWorkspaceCreate201Response.serializer)
      ..add(PrintBlock.serializer)
      ..add(PrintBlockOneOf.serializer)
      ..add(PrintBlockOneOf1.serializer)
      ..add(PrintBlockOneOf1AlignEnum.serializer)
      ..add(PrintBlockOneOf2.serializer)
      ..add(PrintBlockOneOf2AlignEnum.serializer)
      ..add(PrintBlockOneOf3.serializer)
      ..add(PrintBlockOneOf3AlignEnum.serializer)
      ..add(PrintBlockOneOf4.serializer)
      ..add(PrintBlockOneOf4PartiesInner.serializer)
      ..add(PrintBlockOneOf4PartiesInnerPartyEnum.serializer)
      ..add(PrintBlockOneOf5.serializer)
      ..add(PrintBlockOneOf6.serializer)
      ..add(PrintBlockOneOf6StyleEnum.serializer)
      ..add(PrintBlockOneOf7.serializer)
      ..add(PrintBlockOneOfAlignEnum.serializer)
      ..add(PrintBlockOneOfSizeEnum.serializer)
      ..add(PrintJob.serializer)
      ..add(PrintJobClaim.serializer)
      ..add(PrintJobClaimPrinter.serializer)
      ..add(PrintJobKindEnum.serializer)
      ..add(PrintJobReprint.serializer)
      ..add(PrintJobResult.serializer)
      ..add(PrintJobStatusEnum.serializer)
      ..add(PrintLines.serializer)
      ..add(PrintLinesOneOf.serializer)
      ..add(PrintLinesOneOf1.serializer)
      ..add(PrintLinesOneOf1ColumnsInner.serializer)
      ..add(PrintLinesOneOf1ColumnsInnerKeyEnum.serializer)
      ..add(PrintLinesOneOf1Headings.serializer)
      ..add(PrintLinesOneOf1RowsInner.serializer)
      ..add(PrintLinesOneOfItemsInner.serializer)
      ..add(PrintPage.serializer)
      ..add(PrintPageFontEnum.serializer)
      ..add(PrintPageFontSizeEnum.serializer)
      ..add(PrintPayQr.serializer)
      ..add(PrintRow.serializer)
      ..add(Printer.serializer)
      ..add(PrinterCommandLanguageEnum.serializer)
      ..add(PrinterConnectionEnum.serializer)
      ..add(PrinterPaperEnum.serializer)
      ..add(PrinterRolesEnum.serializer)
      ..add(PrinterStatusEnum.serializer)
      ..add(RealtimeEvent.serializer)
      ..add(RealtimeEventEventEnum.serializer)
      ..add(SystemStatus.serializer)
      ..add(SystemStatusBackup.serializer)
      ..add(SystemStatusDatabase.serializer)
      ..add(SystemStatusJobs.serializer)
      ..add(SystemStatusOutbound.serializer)
      ..add(SystemStatusPrinting.serializer)
      ..add(SystemStatusRealtime.serializer)
      ..add(SystemStatusServer.serializer)
      ..add(SystemStatusServerTlsModeEnum.serializer)
      ..add(SystemStatusVersion.serializer)
      ..add(SystemStatusVietqr.serializer)
      ..add(TaxRow.serializer)
      ..add(Workspace.serializer)
      ..add(WorkspaceServiceModeEnum.serializer)
      ..add(WorkspaceTotals.serializer)
      ..add(WorkspaceTotalsTaxesInner.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CatalogItem)]),
          () => ListBuilder<CatalogItem>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(DeviceStaffMember)]),
          () => ListBuilder<DeviceStaffMember>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(PosPrinterStations200ResponseDataInner)]),
          () => ListBuilder<PosPrinterStations200ResponseDataInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(PrintBlockOneOf4PartiesInner)]),
          () => ListBuilder<PrintBlockOneOf4PartiesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PrintJob)]),
          () => ListBuilder<PrintJob>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(PrintLinesOneOf1ColumnsInner)]),
          () => ListBuilder<PrintLinesOneOf1ColumnsInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(PrintLinesOneOf1RowsInner)]),
          () => ListBuilder<PrintLinesOneOf1RowsInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(PrintLinesOneOfItemsInner)]),
          () => ListBuilder<PrintLinesOneOfItemsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Printer)]),
          () => ListBuilder<Printer>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PrinterRolesEnum)]),
          () => ListBuilder<PrinterRolesEnum>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(WorkspaceTotalsTaxesInner)]),
          () => ListBuilder<WorkspaceTotalsTaxesInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
