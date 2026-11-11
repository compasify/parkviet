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

import 'package:pos_api/src/model/append_item.dart';
import 'package:pos_api/src/model/append_items_input.dart';
import 'package:pos_api/src/model/append_items_meta.dart';
import 'package:pos_api/src/model/append_items_result.dart';
import 'package:pos_api/src/model/approval.dart';
import 'package:pos_api/src/model/approval_revision.dart';
import 'package:pos_api/src/model/area.dart';
import 'package:pos_api/src/model/area_input.dart';
import 'package:pos_api/src/model/area_list.dart';
import 'package:pos_api/src/model/area_result.dart';
import 'package:pos_api/src/model/call_board.dart';
import 'package:pos_api/src/model/call_board_preparing_inner.dart';
import 'package:pos_api/src/model/call_board_ready_inner.dart';
import 'package:pos_api/src/model/catalog_item.dart';
import 'package:pos_api/src/model/checklist_input.dart';
import 'package:pos_api/src/model/checklist_outcome.dart';
import 'package:pos_api/src/model/checklist_result.dart';
import 'package:pos_api/src/model/context.dart';
import 'package:pos_api/src/model/context_administration.dart';
import 'package:pos_api/src/model/context_branch.dart';
import 'package:pos_api/src/model/context_staff.dart';
import 'package:pos_api/src/model/context_store.dart';
import 'package:pos_api/src/model/cup_label_settings.dart';
import 'package:pos_api/src/model/device.dart';
import 'package:pos_api/src/model/device_pair_result.dart';
import 'package:pos_api/src/model/device_pairing.dart';
import 'package:pos_api/src/model/device_pairing_qr.dart';
import 'package:pos_api/src/model/device_session.dart';
import 'package:pos_api/src/model/device_session_branch.dart';
import 'package:pos_api/src/model/device_session_staff.dart';
import 'package:pos_api/src/model/device_staff_member.dart';
import 'package:pos_api/src/model/device_staff_sign_in.dart';
import 'package:pos_api/src/model/edit_unsent_line_input.dart';
import 'package:pos_api/src/model/einvoice.dart';
import 'package:pos_api/src/model/einvoice_buyer.dart';
import 'package:pos_api/src/model/einvoice_line.dart';
import 'package:pos_api/src/model/einvoice_sample.dart';
import 'package:pos_api/src/model/einvoice_seller.dart';
import 'package:pos_api/src/model/einvoice_setting.dart';
import 'package:pos_api/src/model/einvoice_setting_input.dart';
import 'package:pos_api/src/model/einvoice_settings.dart';
import 'package:pos_api/src/model/einvoice_settings_providers_inner.dart';
import 'package:pos_api/src/model/einvoice_summary.dart';
import 'package:pos_api/src/model/einvoice_summary_revenue.dart';
import 'package:pos_api/src/model/einvoice_totals.dart';
import 'package:pos_api/src/model/einvoice_totals_taxes_inner.dart';
import 'package:pos_api/src/model/error_response.dart';
import 'package:pos_api/src/model/error_response_error.dart';
import 'package:pos_api/src/model/error_response_error_details.dart';
import 'package:pos_api/src/model/hardware_check.dart';
import 'package:pos_api/src/model/hardware_device.dart';
import 'package:pos_api/src/model/hardware_displays.dart';
import 'package:pos_api/src/model/hardware_einvoice.dart';
import 'package:pos_api/src/model/hardware_printer.dart';
import 'package:pos_api/src/model/hardware_server.dart';
import 'package:pos_api/src/model/hardware_station.dart';
import 'package:pos_api/src/model/hardware_status.dart';
import 'package:pos_api/src/model/ingredient_usage_row.dart';
import 'package:pos_api/src/model/kitchen_all_day_bump_input.dart';
import 'package:pos_api/src/model/kitchen_all_day_row.dart';
import 'package:pos_api/src/model/kitchen_board.dart';
import 'package:pos_api/src/model/kitchen_board_result.dart';
import 'package:pos_api/src/model/kitchen_expo_item.dart';
import 'package:pos_api/src/model/kitchen_expo_order.dart';
import 'package:pos_api/src/model/kitchen_history.dart';
import 'package:pos_api/src/model/kitchen_history_entry.dart';
import 'package:pos_api/src/model/kitchen_history_item.dart';
import 'package:pos_api/src/model/kitchen_history_result.dart';
import 'package:pos_api/src/model/kitchen_menu_item.dart';
import 'package:pos_api/src/model/kitchen_order_served_result.dart';
import 'package:pos_api/src/model/kitchen_order_served_result_data.dart';
import 'package:pos_api/src/model/kitchen_send_input.dart';
import 'package:pos_api/src/model/kitchen_send_meta.dart';
import 'package:pos_api/src/model/kitchen_send_result.dart';
import 'package:pos_api/src/model/kitchen_send_summary.dart';
import 'package:pos_api/src/model/kitchen_settings.dart';
import 'package:pos_api/src/model/kitchen_station.dart';
import 'package:pos_api/src/model/kitchen_station_input.dart';
import 'package:pos_api/src/model/kitchen_station_list.dart';
import 'package:pos_api/src/model/kitchen_station_result.dart';
import 'package:pos_api/src/model/kitchen_ticket.dart';
import 'package:pos_api/src/model/kitchen_ticket_item.dart';
import 'package:pos_api/src/model/kitchen_ticket_item_components_inner.dart';
import 'package:pos_api/src/model/kitchen_ticket_item_modifier.dart';
import 'package:pos_api/src/model/kitchen_ticket_item_modifiers_inner.dart';
import 'package:pos_api/src/model/kitchen_ticket_list.dart';
import 'package:pos_api/src/model/kitchen_ticket_result.dart';
import 'package:pos_api/src/model/kitchen_void.dart';
import 'package:pos_api/src/model/kitchen_void_input.dart';
import 'package:pos_api/src/model/kitchen_void_meta.dart';
import 'package:pos_api/src/model/kitchen_void_result.dart';
import 'package:pos_api/src/model/lease_claim_input.dart';
import 'package:pos_api/src/model/line_component.dart';
import 'package:pos_api/src/model/line_kitchen_status.dart';
import 'package:pos_api/src/model/line_modifier.dart';
import 'package:pos_api/src/model/menu.dart';
import 'package:pos_api/src/model/menu_availability.dart';
import 'package:pos_api/src/model/menu_category.dart';
import 'package:pos_api/src/model/menu_item.dart';
import 'package:pos_api/src/model/menu_item_all_of_variants.dart';
import 'package:pos_api/src/model/menu_item_config.dart';
import 'package:pos_api/src/model/menu_item_config_components_inner.dart';
import 'package:pos_api/src/model/menu_items_meta.dart';
import 'package:pos_api/src/model/menu_margin_row.dart';
import 'package:pos_api/src/model/menu_schedules_inner.dart';
import 'package:pos_api/src/model/menu_tax_defaults.dart';
import 'package:pos_api/src/model/modifier_group.dart';
import 'package:pos_api/src/model/modifier_group_options_inner.dart';
import 'package:pos_api/src/model/modifier_pick.dart';
import 'package:pos_api/src/model/modifier_selection.dart';
import 'package:pos_api/src/model/payment_request.dart';
import 'package:pos_api/src/model/payment_request_input.dart';
import 'package:pos_api/src/model/payment_request_resolve_input.dart';
import 'package:pos_api/src/model/platform_order.dart';
import 'package:pos_api/src/model/platform_order_cancel_input.dart';
import 'package:pos_api/src/model/platform_order_editor.dart';
import 'package:pos_api/src/model/platform_order_input.dart';
import 'package:pos_api/src/model/platform_order_item.dart';
import 'package:pos_api/src/model/platform_order_line_input.dart';
import 'package:pos_api/src/model/platform_order_list.dart';
import 'package:pos_api/src/model/platform_order_result.dart';
import 'package:pos_api/src/model/platform_order_settled.dart';
import 'package:pos_api/src/model/platform_report_row.dart';
import 'package:pos_api/src/model/platform_report_rows.dart';
import 'package:pos_api/src/model/platform_setting.dart';
import 'package:pos_api/src/model/platform_setting_input.dart';
import 'package:pos_api/src/model/platform_setting_result.dart';
import 'package:pos_api/src/model/platform_settings.dart';
import 'package:pos_api/src/model/platform_settings_result.dart';
import 'package:pos_api/src/model/platform_settle_input.dart';
import 'package:pos_api/src/model/platform_settle_order_input.dart';
import 'package:pos_api/src/model/pos_approval_create201_response.dart';
import 'package:pos_api/src/model/pos_catalog200_response.dart';
import 'package:pos_api/src/model/pos_cup_label_settings200_response.dart';
import 'package:pos_api/src/model/pos_cup_label_settings_update_request.dart';
import 'package:pos_api/src/model/pos_cup_label_test_request.dart';
import 'package:pos_api/src/model/pos_device_kitchen_menu_items200_response.dart';
import 'package:pos_api/src/model/pos_device_kitchen_select_station200_response.dart';
import 'package:pos_api/src/model/pos_device_kitchen_select_station_request.dart';
import 'package:pos_api/src/model/pos_device_me200_response.dart';
import 'package:pos_api/src/model/pos_device_pair201_response.dart';
import 'package:pos_api/src/model/pos_device_pair_request.dart';
import 'package:pos_api/src/model/pos_device_print_claim200_response.dart';
import 'package:pos_api/src/model/pos_device_print_report_request.dart';
import 'package:pos_api/src/model/pos_device_staff200_response.dart';
import 'package:pos_api/src/model/pos_device_staff_sign_in201_response.dart';
import 'package:pos_api/src/model/pos_device_staff_sign_in_request.dart';
import 'package:pos_api/src/model/pos_einvoice200_response.dart';
import 'package:pos_api/src/model/pos_einvoice_buyer_request.dart';
import 'package:pos_api/src/model/pos_einvoice_cancel_request.dart';
import 'package:pos_api/src/model/pos_einvoice_replace_request.dart';
import 'package:pos_api/src/model/pos_einvoice_retry200_response.dart';
import 'package:pos_api/src/model/pos_einvoice_retry200_response_data.dart';
import 'package:pos_api/src/model/pos_einvoice_retry_request.dart';
import 'package:pos_api/src/model/pos_einvoice_sample200_response.dart';
import 'package:pos_api/src/model/pos_einvoice_sample_request.dart';
import 'package:pos_api/src/model/pos_einvoice_settings200_response.dart';
import 'package:pos_api/src/model/pos_einvoice_settings_save_request.dart';
import 'package:pos_api/src/model/pos_einvoice_summary200_response.dart';
import 'package:pos_api/src/model/pos_einvoices200_response.dart';
import 'package:pos_api/src/model/pos_hardware_status200_response.dart';
import 'package:pos_api/src/model/pos_kitchen_orders200_response.dart';
import 'package:pos_api/src/model/pos_kitchen_settings200_response.dart';
import 'package:pos_api/src/model/pos_kitchen_settings_update_request.dart';
import 'package:pos_api/src/model/pos_kitchen_station_create_request.dart';
import 'package:pos_api/src/model/pos_menu200_response.dart';
import 'package:pos_api/src/model/pos_menu_categories200_response.dart';
import 'package:pos_api/src/model/pos_menu_favorites200_response.dart';
import 'package:pos_api/src/model/pos_menu_favorites200_response_data.dart';
import 'package:pos_api/src/model/pos_menu_favorites_request.dart';
import 'package:pos_api/src/model/pos_menu_items200_response.dart';
import 'package:pos_api/src/model/pos_menu_sold_out200_response.dart';
import 'package:pos_api/src/model/pos_menu_sold_out_request.dart';
import 'package:pos_api/src/model/pos_modifier_groups200_response.dart';
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
import 'package:pos_api/src/model/pos_recipe200_response.dart';
import 'package:pos_api/src/model/pos_recipe_save_request.dart';
import 'package:pos_api/src/model/pos_recipe_save_request_ingredients_inner.dart';
import 'package:pos_api/src/model/pos_report_ingredient_usage200_response.dart';
import 'package:pos_api/src/model/pos_report_menu_margin200_response.dart';
import 'package:pos_api/src/model/pos_station_route_create201_response.dart';
import 'package:pos_api/src/model/pos_station_route_create_request.dart';
import 'package:pos_api/src/model/pos_station_routes200_response.dart';
import 'package:pos_api/src/model/pos_stock_alert_set_request.dart';
import 'package:pos_api/src/model/pos_stock_alerts200_response.dart';
import 'package:pos_api/src/model/pos_system_status200_response.dart';
import 'package:pos_api/src/model/pos_workspace_create201_response.dart';
import 'package:pos_api/src/model/pos_workspace_cup_labels_reprint201_response.dart';
import 'package:pos_api/src/model/pos_workspace_cup_labels_reprint201_response_data.dart';
import 'package:pos_api/src/model/pos_workspace_cup_labels_reprint_request.dart';
import 'package:pos_api/src/model/pos_workspace_guest_name_request.dart';
import 'package:pos_api/src/model/pos_workspace_kitchen_tickets200_response.dart';
import 'package:pos_api/src/model/pos_workspace_line_modifiers_request.dart';
import 'package:pos_api/src/model/prebill_input.dart';
import 'package:pos_api/src/model/prebill_outcome.dart';
import 'package:pos_api/src/model/prebill_result.dart';
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
import 'package:pos_api/src/model/print_page_label.dart';
import 'package:pos_api/src/model/print_pay_qr.dart';
import 'package:pos_api/src/model/print_row.dart';
import 'package:pos_api/src/model/printer.dart';
import 'package:pos_api/src/model/ready_feed.dart';
import 'package:pos_api/src/model/ready_feed_item.dart';
import 'package:pos_api/src/model/ready_feed_result.dart';
import 'package:pos_api/src/model/realtime_event.dart';
import 'package:pos_api/src/model/recipe.dart';
import 'package:pos_api/src/model/recipe_ingredients_inner.dart';
import 'package:pos_api/src/model/recipe_owner.dart';
import 'package:pos_api/src/model/recipe_owner_versions_inner.dart';
import 'package:pos_api/src/model/resource.dart';
import 'package:pos_api/src/model/resource_board.dart';
import 'package:pos_api/src/model/resource_board_area.dart';
import 'package:pos_api/src/model/resource_board_order.dart';
import 'package:pos_api/src/model/resource_board_result.dart';
import 'package:pos_api/src/model/resource_board_tile.dart';
import 'package:pos_api/src/model/resource_input.dart';
import 'package:pos_api/src/model/resource_list.dart';
import 'package:pos_api/src/model/resource_manual_status_input.dart';
import 'package:pos_api/src/model/resource_ref.dart';
import 'package:pos_api/src/model/resource_result.dart';
import 'package:pos_api/src/model/service_charge_waive_input.dart';
import 'package:pos_api/src/model/staff_ref.dart';
import 'package:pos_api/src/model/station_route.dart';
import 'package:pos_api/src/model/station_route_input.dart';
import 'package:pos_api/src/model/stock_alert.dart';
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
import 'package:pos_api/src/model/table_merge_input.dart';
import 'package:pos_api/src/model/table_move_input.dart';
import 'package:pos_api/src/model/table_open_input.dart';
import 'package:pos_api/src/model/table_pin_input.dart';
import 'package:pos_api/src/model/table_pins.dart';
import 'package:pos_api/src/model/table_pins_result.dart';
import 'package:pos_api/src/model/table_settings.dart';
import 'package:pos_api/src/model/table_settings_input.dart';
import 'package:pos_api/src/model/table_settings_result.dart';
import 'package:pos_api/src/model/table_split_input.dart';
import 'package:pos_api/src/model/table_split_orders.dart';
import 'package:pos_api/src/model/table_split_result.dart';
import 'package:pos_api/src/model/table_tax_category.dart';
import 'package:pos_api/src/model/tax_row.dart';
import 'package:pos_api/src/model/workspace.dart';
import 'package:pos_api/src/model/workspace_line.dart';
import 'package:pos_api/src/model/workspace_prebill.dart';
import 'package:pos_api/src/model/workspace_result.dart';
import 'package:pos_api/src/model/workspace_service_charge.dart';
import 'package:pos_api/src/model/workspace_totals.dart';
import 'package:pos_api/src/model/workspace_totals_taxes_inner.dart';

part 'serializers.g.dart';

@SerializersFor([
  AppendItem,
  AppendItemsInput,
  AppendItemsMeta,
  AppendItemsResult,
  Approval,
  ApprovalRevision,
  Area,
  AreaInput,
  AreaList,
  AreaResult,
  CallBoard,
  CallBoardPreparingInner,
  CallBoardReadyInner,
  CatalogItem,
  ChecklistInput,
  ChecklistOutcome,
  ChecklistResult,
  Context,
  ContextAdministration,
  ContextBranch,
  ContextStaff,
  ContextStore,
  CupLabelSettings,
  Device,
  DevicePairResult,
  DevicePairing,
  DevicePairingQr,
  DeviceSession,
  DeviceSessionBranch,
  DeviceSessionStaff,
  DeviceStaffMember,
  DeviceStaffSignIn,
  EditUnsentLineInput,
  Einvoice,
  EinvoiceBuyer,
  EinvoiceLine,
  EinvoiceSample,
  EinvoiceSeller,
  EinvoiceSetting,
  EinvoiceSettingInput,
  EinvoiceSettings,
  EinvoiceSettingsProvidersInner,
  EinvoiceSummary,
  EinvoiceSummaryRevenue,
  EinvoiceTotals,
  EinvoiceTotalsTaxesInner,
  ErrorResponse,
  ErrorResponseError,
  ErrorResponseErrorDetails,
  HardwareCheck,
  HardwareDevice,
  HardwareDisplays,
  HardwareEinvoice,
  HardwarePrinter,
  HardwareServer,
  HardwareStation,
  HardwareStatus,
  IngredientUsageRow,
  KitchenAllDayBumpInput,
  KitchenAllDayRow,
  KitchenBoard,
  KitchenBoardResult,
  KitchenExpoItem,
  KitchenExpoOrder,
  KitchenHistory,
  KitchenHistoryEntry,
  KitchenHistoryItem,
  KitchenHistoryResult,
  KitchenMenuItem,
  KitchenOrderServedResult,
  KitchenOrderServedResultData,
  KitchenSendInput,
  KitchenSendMeta,
  KitchenSendResult,
  KitchenSendSummary,
  KitchenSettings,
  KitchenStation,
  KitchenStationInput,
  $KitchenStationInput,
  KitchenStationList,
  KitchenStationResult,
  KitchenTicket,
  KitchenTicketItem,
  KitchenTicketItemComponentsInner,
  KitchenTicketItemModifier,
  KitchenTicketItemModifiersInner,
  KitchenTicketList,
  KitchenTicketResult,
  KitchenVoid,
  KitchenVoidInput,
  KitchenVoidMeta,
  KitchenVoidResult,
  LeaseClaimInput,
  LineComponent,
  LineKitchenStatus,
  LineModifier,
  Menu,
  MenuAvailability,
  MenuCategory,
  MenuItem,
  MenuItemAllOfVariants,
  MenuItemConfig,
  $MenuItemConfig,
  MenuItemConfigComponentsInner,
  MenuItemsMeta,
  MenuMarginRow,
  MenuSchedulesInner,
  MenuTaxDefaults,
  ModifierGroup,
  ModifierGroupOptionsInner,
  ModifierPick,
  ModifierSelection,
  PaymentRequest,
  PaymentRequestInput,
  PaymentRequestResolveInput,
  PlatformOrder,
  PlatformOrderCancelInput,
  PlatformOrderEditor,
  PlatformOrderInput,
  PlatformOrderItem,
  PlatformOrderLineInput,
  PlatformOrderList,
  PlatformOrderResult,
  PlatformOrderSettled,
  PlatformReportRow,
  PlatformReportRows,
  PlatformSetting,
  PlatformSettingInput,
  PlatformSettingResult,
  PlatformSettings,
  PlatformSettingsResult,
  PlatformSettleInput,
  PlatformSettleOrderInput,
  PosApprovalCreate201Response,
  PosCatalog200Response,
  PosCupLabelSettings200Response,
  PosCupLabelSettingsUpdateRequest,
  PosCupLabelTestRequest,
  PosDeviceKitchenMenuItems200Response,
  PosDeviceKitchenSelectStation200Response,
  PosDeviceKitchenSelectStationRequest,
  PosDeviceMe200Response,
  PosDevicePair201Response,
  PosDevicePairRequest,
  PosDevicePrintClaim200Response,
  PosDevicePrintReportRequest,
  PosDeviceStaff200Response,
  PosDeviceStaffSignIn201Response,
  PosDeviceStaffSignInRequest,
  PosEinvoice200Response,
  PosEinvoiceBuyerRequest,
  PosEinvoiceCancelRequest,
  PosEinvoiceReplaceRequest,
  PosEinvoiceRetry200Response,
  PosEinvoiceRetry200ResponseData,
  PosEinvoiceRetryRequest,
  PosEinvoiceSample200Response,
  PosEinvoiceSampleRequest,
  PosEinvoiceSettings200Response,
  PosEinvoiceSettingsSaveRequest,
  PosEinvoiceSummary200Response,
  PosEinvoices200Response,
  PosHardwareStatus200Response,
  PosKitchenOrders200Response,
  PosKitchenSettings200Response,
  PosKitchenSettingsUpdateRequest,
  PosKitchenStationCreateRequest,
  PosMenu200Response,
  PosMenuCategories200Response,
  PosMenuFavorites200Response,
  PosMenuFavorites200ResponseData,
  PosMenuFavoritesRequest,
  PosMenuItems200Response,
  PosMenuSoldOut200Response,
  PosMenuSoldOutRequest,
  PosModifierGroups200Response,
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
  PosRecipe200Response,
  PosRecipeSaveRequest,
  PosRecipeSaveRequestIngredientsInner,
  PosReportIngredientUsage200Response,
  PosReportMenuMargin200Response,
  PosStationRouteCreate201Response,
  PosStationRouteCreateRequest,
  PosStationRoutes200Response,
  PosStockAlertSetRequest,
  PosStockAlerts200Response,
  PosSystemStatus200Response,
  PosWorkspaceCreate201Response,
  PosWorkspaceCupLabelsReprint201Response,
  PosWorkspaceCupLabelsReprint201ResponseData,
  PosWorkspaceCupLabelsReprintRequest,
  PosWorkspaceGuestNameRequest,
  PosWorkspaceKitchenTickets200Response,
  PosWorkspaceLineModifiersRequest,
  PrebillInput,
  PrebillOutcome,
  PrebillResult,
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
  PrintPageLabel,
  PrintPayQr,
  PrintRow,
  Printer,
  ReadyFeed,
  ReadyFeedItem,
  ReadyFeedResult,
  RealtimeEvent,
  Recipe,
  RecipeIngredientsInner,
  RecipeOwner,
  RecipeOwnerVersionsInner,
  Resource,
  ResourceBoard,
  ResourceBoardArea,
  ResourceBoardOrder,
  ResourceBoardResult,
  ResourceBoardTile,
  ResourceInput,
  ResourceList,
  ResourceManualStatusInput,
  ResourceRef,
  ResourceResult,
  ServiceChargeWaiveInput,
  StaffRef,
  StationRoute,
  StationRouteInput,
  $StationRouteInput,
  StockAlert,
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
  TableMergeInput,
  TableMoveInput,
  TableOpenInput,
  TablePinInput,
  TablePins,
  TablePinsResult,
  TableSettings,
  TableSettingsInput,
  TableSettingsResult,
  TableSplitInput,
  TableSplitOrders,
  TableSplitResult,
  TableTaxCategory,
  TaxRow,
  Workspace,
  WorkspaceLine,
  WorkspacePrebill,
  WorkspaceResult,
  WorkspaceServiceCharge,
  WorkspaceTotals,
  WorkspaceTotalsTaxesInner,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PrintLinesOneOfItemsInner)]),
        () => ListBuilder<PrintLinesOneOfItemsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenSendSummary)]),
        () => ListBuilder<KitchenSendSummary>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(StationRoute)]),
        () => ListBuilder<StationRoute>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(PosPrinterStations200ResponseDataInner)]),
        () => ListBuilder<PosPrinterStations200ResponseDataInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(EinvoiceLine)]),
        () => ListBuilder<EinvoiceLine>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenHistoryEntry)]),
        () => ListBuilder<KitchenHistoryEntry>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PlatformSettleOrderInput)]),
        () => ListBuilder<PlatformSettleOrderInput>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(EinvoiceSettingsProvidersInner)]),
        () => ListBuilder<EinvoiceSettingsProvidersInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ModifierPick)]),
        () => ListBuilder<ModifierPick>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [
          FullType(BuiltMap, [FullType(String), FullType(JsonObject)])
        ]),
        () => ListBuilder<BuiltMap<String, JsonObject>>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(WorkspaceLine)]),
        () => ListBuilder<WorkspaceLine>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MenuItemConfig)]),
        () => ListBuilder<MenuItemConfig>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ModifierGroup)]),
        () => ListBuilder<ModifierGroup>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CatalogItem)]),
        () => ListBuilder<CatalogItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(LineComponent)]),
        () => ListBuilder<LineComponent>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MenuItem)]),
        () => ListBuilder<MenuItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(RecipeIngredientsInner)]),
        () => ListBuilder<RecipeIngredientsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PrintBlockOneOf4PartiesInner)]),
        () => ListBuilder<PrintBlockOneOf4PartiesInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MenuItemConfigComponentsInner)]),
        () => ListBuilder<MenuItemConfigComponentsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(DeviceStaffMember)]),
        () => ListBuilder<DeviceStaffMember>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(EinvoiceTotalsTaxesInner)]),
        () => ListBuilder<EinvoiceTotalsTaxesInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ReadyFeedItem)]),
        () => ListBuilder<ReadyFeedItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PrintLinesOneOf1ColumnsInner)]),
        () => ListBuilder<PrintLinesOneOf1ColumnsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenTicketItemModifier)]),
        () => ListBuilder<KitchenTicketItemModifier>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(PosRecipeSaveRequestIngredientsInner)]),
        () => ListBuilder<PosRecipeSaveRequestIngredientsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(HardwareStation)]),
        () => ListBuilder<HardwareStation>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PlatformReportRow)]),
        () => ListBuilder<PlatformReportRow>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(WorkspaceTotalsTaxesInner)]),
        () => ListBuilder<WorkspaceTotalsTaxesInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenMenuItem)]),
        () => ListBuilder<KitchenMenuItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(String)]),
        () => MapBuilder<String, String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(IngredientUsageRow)]),
        () => ListBuilder<IngredientUsageRow>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(AppendItem)]),
        () => ListBuilder<AppendItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Resource)]),
        () => ListBuilder<Resource>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(TableTaxCategory)]),
        () => ListBuilder<TableTaxCategory>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ModifierSelection)]),
        () => ListBuilder<ModifierSelection>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenTicketItem)]),
        () => ListBuilder<KitchenTicketItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(StockAlert)]),
        () => ListBuilder<StockAlert>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenStation)]),
        () => ListBuilder<KitchenStation>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MenuItemAllOfVariants)]),
        () => ListBuilder<MenuItemAllOfVariants>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PlatformOrderLineInput)]),
        () => ListBuilder<PlatformOrderLineInput>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ModifierGroupOptionsInner)]),
        () => ListBuilder<ModifierGroupOptionsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(int)]),
        () => MapBuilder<String, int>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Area)]),
        () => ListBuilder<Area>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MenuMarginRow)]),
        () => ListBuilder<MenuMarginRow>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PrintJob)]),
        () => ListBuilder<PrintJob>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ResourceBoardArea)]),
        () => ListBuilder<ResourceBoardArea>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PlatformOrder)]),
        () => ListBuilder<PlatformOrder>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ResourceBoardOrder)]),
        () => ListBuilder<ResourceBoardOrder>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Printer)]),
        () => ListBuilder<Printer>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MenuSchedulesInner)]),
        () => ListBuilder<MenuSchedulesInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(RecipeOwnerVersionsInner)]),
        () => ListBuilder<RecipeOwnerVersionsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ContextBranch)]),
        () => ListBuilder<ContextBranch>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(LineModifier)]),
        () => ListBuilder<LineModifier>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenHistoryItem)]),
        () => ListBuilder<KitchenHistoryItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Einvoice)]),
        () => ListBuilder<Einvoice>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(HardwareDevice)]),
        () => ListBuilder<HardwareDevice>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenTicketItemModifiersInner)]),
        () => ListBuilder<KitchenTicketItemModifiersInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(HardwarePrinter)]),
        () => ListBuilder<HardwarePrinter>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(HardwareCheck)]),
        () => ListBuilder<HardwareCheck>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenTicket)]),
        () => ListBuilder<KitchenTicket>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PlatformOrderItem)]),
        () => ListBuilder<PlatformOrderItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MenuCategory)]),
        () => ListBuilder<MenuCategory>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CallBoardReadyInner)]),
        () => ListBuilder<CallBoardReadyInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenExpoItem)]),
        () => ListBuilder<KitchenExpoItem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(EinvoiceSetting)]),
        () => ListBuilder<EinvoiceSetting>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ResourceBoardTile)]),
        () => ListBuilder<ResourceBoardTile>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CallBoardPreparingInner)]),
        () => ListBuilder<CallBoardPreparingInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenTicketItemComponentsInner)]),
        () => ListBuilder<KitchenTicketItemComponentsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PrintLinesOneOf1RowsInner)]),
        () => ListBuilder<PrintLinesOneOf1RowsInner>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
        () => MapBuilder<String, JsonObject?>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenExpoOrder)]),
        () => ListBuilder<KitchenExpoOrder>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PlatformSetting)]),
        () => ListBuilder<PlatformSetting>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(KitchenAllDayRow)]),
        () => ListBuilder<KitchenAllDayRow>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..add(KitchenStationInput.serializer)
      ..add(MenuItemConfig.serializer)
      ..add(StationRouteInput.serializer)
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
