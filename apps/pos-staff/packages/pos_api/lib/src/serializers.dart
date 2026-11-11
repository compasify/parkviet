//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:pos_api/src/date_serializer.dart';
import 'package:pos_api/src/model/date.dart';

import 'package:pos_api/src/model/approval.dart';
import 'package:pos_api/src/model/approval_revision.dart';
import 'package:pos_api/src/model/catalog_item.dart';
import 'package:pos_api/src/model/context.dart';
import 'package:pos_api/src/model/context_administration.dart';
import 'package:pos_api/src/model/context_staff.dart';
import 'package:pos_api/src/model/context_store.dart';
import 'package:pos_api/src/model/device.dart';
import 'package:pos_api/src/model/device_pair_result.dart';
import 'package:pos_api/src/model/device_pairing.dart';
import 'package:pos_api/src/model/device_pairing_qr.dart';
import 'package:pos_api/src/model/device_session.dart';
import 'package:pos_api/src/model/device_session_branch.dart';
import 'package:pos_api/src/model/device_session_staff.dart';
import 'package:pos_api/src/model/device_staff_member.dart';
import 'package:pos_api/src/model/device_staff_sign_in.dart';
import 'package:pos_api/src/model/error_response.dart';
import 'package:pos_api/src/model/error_response_error.dart';
import 'package:pos_api/src/model/error_response_error_details.dart';
import 'package:pos_api/src/model/pos_approval_create201_response.dart';
import 'package:pos_api/src/model/pos_catalog200_response.dart';
import 'package:pos_api/src/model/pos_device_me200_response.dart';
import 'package:pos_api/src/model/pos_device_pair201_response.dart';
import 'package:pos_api/src/model/pos_device_pair_request.dart';
import 'package:pos_api/src/model/pos_device_print_claim200_response.dart';
import 'package:pos_api/src/model/pos_device_print_report_request.dart';
import 'package:pos_api/src/model/pos_device_staff200_response.dart';
import 'package:pos_api/src/model/pos_device_staff_sign_in201_response.dart';
import 'package:pos_api/src/model/pos_device_staff_sign_in_request.dart';
import 'package:pos_api/src/model/pos_print_job_cancel200_response.dart';
import 'package:pos_api/src/model/pos_print_job_create201_response.dart';
import 'package:pos_api/src/model/pos_print_job_create_request.dart';
import 'package:pos_api/src/model/pos_print_job_reprint_request.dart';
import 'package:pos_api/src/model/pos_print_jobs200_response.dart';
import 'package:pos_api/src/model/pos_printer_create201_response.dart';
import 'package:pos_api/src/model/pos_printer_create_request.dart';
import 'package:pos_api/src/model/pos_printer_delete200_response.dart';
import 'package:pos_api/src/model/pos_printer_delete200_response_data.dart';
import 'package:pos_api/src/model/pos_printer_stations200_response.dart';
import 'package:pos_api/src/model/pos_printer_stations200_response_data_inner.dart';
import 'package:pos_api/src/model/pos_printer_test200_response.dart';
import 'package:pos_api/src/model/pos_printer_test200_response_data.dart';
import 'package:pos_api/src/model/pos_printer_update_request.dart';
import 'package:pos_api/src/model/pos_printers200_response.dart';
import 'package:pos_api/src/model/pos_receipt_print_void200_response.dart';
import 'package:pos_api/src/model/pos_receipt_print_void200_response_data.dart';
import 'package:pos_api/src/model/pos_receipt_print_void_request.dart';
import 'package:pos_api/src/model/pos_system_status200_response.dart';
import 'package:pos_api/src/model/pos_workspace_create201_response.dart';
import 'package:pos_api/src/model/print_block.dart';
import 'package:pos_api/src/model/print_block_one_of.dart';
import 'package:pos_api/src/model/print_block_one_of1.dart';
import 'package:pos_api/src/model/print_block_one_of2.dart';
import 'package:pos_api/src/model/print_block_one_of3.dart';
import 'package:pos_api/src/model/print_block_one_of4.dart';
import 'package:pos_api/src/model/print_block_one_of4_parties_inner.dart';
import 'package:pos_api/src/model/print_block_one_of5.dart';
import 'package:pos_api/src/model/print_block_one_of6.dart';
import 'package:pos_api/src/model/print_block_one_of7.dart';
import 'package:pos_api/src/model/print_job.dart';
import 'package:pos_api/src/model/print_job_claim.dart';
import 'package:pos_api/src/model/print_job_claim_printer.dart';
import 'package:pos_api/src/model/print_job_reprint.dart';
import 'package:pos_api/src/model/print_job_result.dart';
import 'package:pos_api/src/model/print_lines.dart';
import 'package:pos_api/src/model/print_lines_one_of.dart';
import 'package:pos_api/src/model/print_lines_one_of1.dart';
import 'package:pos_api/src/model/print_lines_one_of1_columns_inner.dart';
import 'package:pos_api/src/model/print_lines_one_of1_headings.dart';
import 'package:pos_api/src/model/print_lines_one_of1_rows_inner.dart';
import 'package:pos_api/src/model/print_lines_one_of_items_inner.dart';
import 'package:pos_api/src/model/print_page.dart';
import 'package:pos_api/src/model/print_pay_qr.dart';
import 'package:pos_api/src/model/print_row.dart';
import 'package:pos_api/src/model/printer.dart';
import 'package:pos_api/src/model/realtime_event.dart';
import 'package:pos_api/src/model/system_status.dart';
import 'package:pos_api/src/model/system_status_backup.dart';
import 'package:pos_api/src/model/system_status_database.dart';
import 'package:pos_api/src/model/system_status_jobs.dart';
import 'package:pos_api/src/model/system_status_outbound.dart';
import 'package:pos_api/src/model/system_status_printing.dart';
import 'package:pos_api/src/model/system_status_realtime.dart';
import 'package:pos_api/src/model/system_status_server.dart';
import 'package:pos_api/src/model/system_status_version.dart';
import 'package:pos_api/src/model/system_status_vietqr.dart';
import 'package:pos_api/src/model/tax_row.dart';
import 'package:pos_api/src/model/workspace.dart';
import 'package:pos_api/src/model/workspace_totals.dart';
import 'package:pos_api/src/model/workspace_totals_taxes_inner.dart';

part 'serializers.g.dart';

@SerializersFor([
  Approval,
  ApprovalRevision,
  CatalogItem,
  Context,
  ContextAdministration,
  ContextStaff,
  ContextStore,
  Device,
  DevicePairResult,
  DevicePairing,
  DevicePairingQr,
  DeviceSession,
  DeviceSessionBranch,
  DeviceSessionStaff,
  DeviceStaffMember,
  DeviceStaffSignIn,
  ErrorResponse,
  ErrorResponseError,
  ErrorResponseErrorDetails,
  PosApprovalCreate201Response,
  PosCatalog200Response,
  PosDeviceMe200Response,
  PosDevicePair201Response,
  PosDevicePairRequest,
  PosDevicePrintClaim200Response,
  PosDevicePrintReportRequest,
  PosDeviceStaff200Response,
  PosDeviceStaffSignIn201Response,
  PosDeviceStaffSignInRequest,
  PosPrintJobCancel200Response,
  PosPrintJobCreate201Response,
  PosPrintJobCreateRequest,
  PosPrintJobReprintRequest,
  PosPrintJobs200Response,
  PosPrinterCreate201Response,
  PosPrinterCreateRequest,
  PosPrinterDelete200Response,
  PosPrinterDelete200ResponseData,
  PosPrinterStations200Response,
  PosPrinterStations200ResponseDataInner,
  PosPrinterTest200Response,
  PosPrinterTest200ResponseData,
  PosPrinterUpdateRequest,
  PosPrinters200Response,
  PosReceiptPrintVoid200Response,
  PosReceiptPrintVoid200ResponseData,
  PosReceiptPrintVoidRequest,
  PosSystemStatus200Response,
  PosWorkspaceCreate201Response,
  PrintBlock,
  PrintBlockOneOf,
  PrintBlockOneOf1,
  PrintBlockOneOf2,
  PrintBlockOneOf3,
  PrintBlockOneOf4,
  PrintBlockOneOf4PartiesInner,
  PrintBlockOneOf5,
  PrintBlockOneOf6,
  PrintBlockOneOf7,
  PrintJob,
  PrintJobClaim,
  PrintJobClaimPrinter,
  PrintJobReprint,
  PrintJobResult,
  PrintLines,
  PrintLinesOneOf,
  PrintLinesOneOf1,
  PrintLinesOneOf1ColumnsInner,
  PrintLinesOneOf1Headings,
  PrintLinesOneOf1RowsInner,
  PrintLinesOneOfItemsInner,
  PrintPage,
  PrintPayQr,
  PrintRow,
  Printer,
  RealtimeEvent,
  SystemStatus,
  SystemStatusBackup,
  SystemStatusDatabase,
  SystemStatusJobs,
  SystemStatusOutbound,
  SystemStatusPrinting,
  SystemStatusRealtime,
  SystemStatusServer,
  SystemStatusVersion,
  SystemStatusVietqr,
  TaxRow,
  Workspace,
  WorkspaceTotals,
  WorkspaceTotalsTaxesInner,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Printer)]),
        () => ListBuilder<Printer>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(String)]),
        () => MapBuilder<String, String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PrintLinesOneOfItemsInner)]),
        () => ListBuilder<PrintLinesOneOfItemsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(DeviceStaffMember)]),
        () => ListBuilder<DeviceStaffMember>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(PosPrinterStations200ResponseDataInner)]),
        () => ListBuilder<PosPrinterStations200ResponseDataInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PrintLinesOneOf1RowsInner)]),
        () => ListBuilder<PrintLinesOneOf1RowsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(WorkspaceTotalsTaxesInner)]),
        () => ListBuilder<WorkspaceTotalsTaxesInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PrintJob)]),
        () => ListBuilder<PrintJob>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CatalogItem)]),
        () => ListBuilder<CatalogItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PrintLinesOneOf1ColumnsInner)]),
        () => ListBuilder<PrintLinesOneOf1ColumnsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PrintBlockOneOf4PartiesInner)]),
        () => ListBuilder<PrintBlockOneOf4PartiesInner>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
