// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add($KitchenStationInput.serializer)
      ..add($MenuItemConfig.serializer)
      ..add($StationRouteInput.serializer)
      ..add(Approval.serializer)
      ..add(ApprovalRevision.serializer)
      ..add(CallBoard.serializer)
      ..add(CallBoardPreparingInner.serializer)
      ..add(CallBoardReadyInner.serializer)
      ..add(CatalogItem.serializer)
      ..add(Context.serializer)
      ..add(ContextAdministration.serializer)
      ..add(ContextEinvoiceTypeEnum.serializer)
      ..add(ContextStaff.serializer)
      ..add(ContextStore.serializer)
      ..add(CupLabelSettings.serializer)
      ..add(CupLabelSettingsFieldsEnum.serializer)
      ..add(CupLabelSettingsSizeEnum.serializer)
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
      ..add(Einvoice.serializer)
      ..add(EinvoiceBuyer.serializer)
      ..add(EinvoiceInvoiceTypeEnum.serializer)
      ..add(EinvoiceLine.serializer)
      ..add(EinvoiceLineKindEnum.serializer)
      ..add(EinvoicePaymentMethodEnum.serializer)
      ..add(EinvoiceRelationEnum.serializer)
      ..add(EinvoiceSample.serializer)
      ..add(EinvoiceSeller.serializer)
      ..add(EinvoiceSetting.serializer)
      ..add(EinvoiceSettingInput.serializer)
      ..add(EinvoiceSettingInputStatusEnum.serializer)
      ..add(EinvoiceSettingStatusEnum.serializer)
      ..add(EinvoiceSettings.serializer)
      ..add(EinvoiceSettingsEinvoiceTypeEnum.serializer)
      ..add(EinvoiceSettingsProvidersInner.serializer)
      ..add(EinvoiceStatusEnum.serializer)
      ..add(EinvoiceSummary.serializer)
      ..add(EinvoiceSummaryEinvoiceTypeEnum.serializer)
      ..add(EinvoiceSummaryRevenue.serializer)
      ..add(EinvoiceSummaryRevenueLevelEnum.serializer)
      ..add(EinvoiceTotals.serializer)
      ..add(EinvoiceTotalsTaxesInner.serializer)
      ..add(ErrorResponse.serializer)
      ..add(ErrorResponseError.serializer)
      ..add(ErrorResponseErrorDetails.serializer)
      ..add(IngredientUsageRow.serializer)
      ..add(KitchenBoard.serializer)
      ..add(KitchenBoardResult.serializer)
      ..add(KitchenMenuItem.serializer)
      ..add(KitchenOrderServedResult.serializer)
      ..add(KitchenOrderServedResultData.serializer)
      ..add(KitchenSettings.serializer)
      ..add(KitchenSettingsKitchenSendTriggerEnum.serializer)
      ..add(KitchenStation.serializer)
      ..add(KitchenStationInputKindEnum.serializer)
      ..add(KitchenStationKindEnum.serializer)
      ..add(KitchenStationList.serializer)
      ..add(KitchenStationResult.serializer)
      ..add(KitchenTicket.serializer)
      ..add(KitchenTicketItem.serializer)
      ..add(KitchenTicketItemComponentsInner.serializer)
      ..add(KitchenTicketItemModifiersInner.serializer)
      ..add(KitchenTicketItemStatusEnum.serializer)
      ..add(KitchenTicketKindEnum.serializer)
      ..add(KitchenTicketResult.serializer)
      ..add(KitchenTicketStationKindEnum.serializer)
      ..add(LineComponent.serializer)
      ..add(LineModifier.serializer)
      ..add(Menu.serializer)
      ..add(MenuAvailability.serializer)
      ..add(MenuCategory.serializer)
      ..add(MenuItem.serializer)
      ..add(MenuItemAllOfVariants.serializer)
      ..add(MenuItemConfigComponentsInner.serializer)
      ..add(MenuItemConfigKindEnum.serializer)
      ..add(MenuMarginRow.serializer)
      ..add(MenuSchedulesInner.serializer)
      ..add(ModifierGroup.serializer)
      ..add(ModifierGroupOptionsInner.serializer)
      ..add(ModifierSelection.serializer)
      ..add(PlatformOrder.serializer)
      ..add(PlatformOrderCancelInput.serializer)
      ..add(PlatformOrderEditor.serializer)
      ..add(PlatformOrderInput.serializer)
      ..add(PlatformOrderInputPlatformEnum.serializer)
      ..add(PlatformOrderItem.serializer)
      ..add(PlatformOrderLineInput.serializer)
      ..add(PlatformOrderList.serializer)
      ..add(PlatformOrderPlatformEnum.serializer)
      ..add(PlatformOrderResult.serializer)
      ..add(PlatformOrderSettled.serializer)
      ..add(PlatformOrderStatusEnum.serializer)
      ..add(PlatformReportRow.serializer)
      ..add(PlatformReportRowPlatformEnum.serializer)
      ..add(PlatformReportRows.serializer)
      ..add(PlatformSetting.serializer)
      ..add(PlatformSettingInput.serializer)
      ..add(PlatformSettingInputPlatformEnum.serializer)
      ..add(PlatformSettingInputStatusEnum.serializer)
      ..add(PlatformSettingPlatformEnum.serializer)
      ..add(PlatformSettingResult.serializer)
      ..add(PlatformSettingStatusEnum.serializer)
      ..add(PlatformSettings.serializer)
      ..add(PlatformSettingsResult.serializer)
      ..add(PlatformSettleInput.serializer)
      ..add(PlatformSettleOrderInput.serializer)
      ..add(PosApprovalCreate201Response.serializer)
      ..add(PosCatalog200Response.serializer)
      ..add(PosCupLabelSettings200Response.serializer)
      ..add(PosCupLabelSettingsUpdateRequest.serializer)
      ..add(PosCupLabelSettingsUpdateRequestFieldsEnum.serializer)
      ..add(PosCupLabelSettingsUpdateRequestSizeEnum.serializer)
      ..add(PosCupLabelTestRequest.serializer)
      ..add(PosDeviceKitchenMenuItems200Response.serializer)
      ..add(PosDeviceKitchenSelectStation200Response.serializer)
      ..add(PosDeviceKitchenSelectStationRequest.serializer)
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
      ..add(PosEinvoice200Response.serializer)
      ..add(PosEinvoiceBuyerRequest.serializer)
      ..add(PosEinvoiceCancelRequest.serializer)
      ..add(PosEinvoiceReplaceRequest.serializer)
      ..add(PosEinvoiceRetry200Response.serializer)
      ..add(PosEinvoiceRetry200ResponseData.serializer)
      ..add(PosEinvoiceRetryRequest.serializer)
      ..add(PosEinvoiceSample200Response.serializer)
      ..add(PosEinvoiceSampleRequest.serializer)
      ..add(PosEinvoiceSettings200Response.serializer)
      ..add(PosEinvoiceSettingsSaveRequest.serializer)
      ..add(PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum.serializer)
      ..add(PosEinvoiceSummary200Response.serializer)
      ..add(PosEinvoices200Response.serializer)
      ..add(PosKitchenOrders200Response.serializer)
      ..add(PosKitchenSend201Response.serializer)
      ..add(PosKitchenSend201ResponseMeta.serializer)
      ..add(PosKitchenSendRequest.serializer)
      ..add(PosKitchenSettings200Response.serializer)
      ..add(PosKitchenSettingsUpdateRequest.serializer)
      ..add(PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum.serializer)
      ..add(PosKitchenStationCreateRequest.serializer)
      ..add(PosMenu200Response.serializer)
      ..add(PosMenuCategories200Response.serializer)
      ..add(PosMenuFavorites200Response.serializer)
      ..add(PosMenuFavorites200ResponseData.serializer)
      ..add(PosMenuFavoritesRequest.serializer)
      ..add(PosMenuItems200Response.serializer)
      ..add(PosMenuSoldOut200Response.serializer)
      ..add(PosMenuSoldOutRequest.serializer)
      ..add(PosModifierGroups200Response.serializer)
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
      ..add(PosRecipe200Response.serializer)
      ..add(PosRecipeSaveRequest.serializer)
      ..add(PosRecipeSaveRequestIngredientsInner.serializer)
      ..add(PosReportIngredientUsage200Response.serializer)
      ..add(PosReportMenuMargin200Response.serializer)
      ..add(PosStationRouteCreate201Response.serializer)
      ..add(PosStationRouteCreateRequest.serializer)
      ..add(PosStationRoutes200Response.serializer)
      ..add(PosStockAlertSetRequest.serializer)
      ..add(PosStockAlerts200Response.serializer)
      ..add(PosSystemStatus200Response.serializer)
      ..add(PosWorkspaceCreate201Response.serializer)
      ..add(PosWorkspaceCupLabelsReprint201Response.serializer)
      ..add(PosWorkspaceCupLabelsReprint201ResponseData.serializer)
      ..add(PosWorkspaceCupLabelsReprintRequest.serializer)
      ..add(PosWorkspaceGuestNameRequest.serializer)
      ..add(PosWorkspaceKitchenTickets200Response.serializer)
      ..add(PosWorkspaceLineModifiersRequest.serializer)
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
      ..add(PrintPageLabel.serializer)
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
      ..add(Recipe.serializer)
      ..add(RecipeIngredientsInner.serializer)
      ..add(RecipeOwner.serializer)
      ..add(RecipeOwnerOwnerTypeEnum.serializer)
      ..add(RecipeOwnerVersionsInner.serializer)
      ..add(StationRoute.serializer)
      ..add(StockAlert.serializer)
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
      ..add(WorkspaceLine.serializer)
      ..add(WorkspaceLineKindEnum.serializer)
      ..add(WorkspaceServiceModeEnum.serializer)
      ..add(WorkspaceTotals.serializer)
      ..add(WorkspaceTotalsTaxesInner.serializer)
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CallBoardPreparingInner)]),
          () => ListBuilder<CallBoardPreparingInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CallBoardReadyInner)]),
          () => ListBuilder<CallBoardReadyInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CatalogItem)]),
          () => ListBuilder<CatalogItem>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CupLabelSettingsFieldsEnum)]),
          () => ListBuilder<CupLabelSettingsFieldsEnum>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(DeviceStaffMember)]),
          () => ListBuilder<DeviceStaffMember>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Einvoice)]),
          () => ListBuilder<Einvoice>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(EinvoiceLine)]),
          () => ListBuilder<EinvoiceLine>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(EinvoiceSettingsProvidersInner)]),
          () => ListBuilder<EinvoiceSettingsProvidersInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(EinvoiceSetting)]),
          () => ListBuilder<EinvoiceSetting>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(EinvoiceTotalsTaxesInner)]),
          () => ListBuilder<EinvoiceTotalsTaxesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(IngredientUsageRow)]),
          () => ListBuilder<IngredientUsageRow>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenMenuItem)]),
          () => ListBuilder<KitchenMenuItem>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenStation)]),
          () => ListBuilder<KitchenStation>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenStation)]),
          () => ListBuilder<KitchenStation>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenTicket)]),
          () => ListBuilder<KitchenTicket>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenTicket)]),
          () => ListBuilder<KitchenTicket>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenTicket)]),
          () => ListBuilder<KitchenTicket>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenTicket)]),
          () => ListBuilder<KitchenTicket>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenTicket)]),
          () => ListBuilder<KitchenTicket>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(KitchenTicketItemModifiersInner)]),
          () => ListBuilder<KitchenTicketItemModifiersInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(KitchenTicketItemComponentsInner)]),
          () => ListBuilder<KitchenTicketItemComponentsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(LineModifier)]),
          () => ListBuilder<LineModifier>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(LineComponent)]),
          () => ListBuilder<LineComponent>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MenuCategory)]),
          () => ListBuilder<MenuCategory>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MenuCategory)]),
          () => ListBuilder<MenuCategory>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MenuItem)]),
          () => ListBuilder<MenuItem>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ModifierGroup)]),
          () => ListBuilder<ModifierGroup>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MenuSchedulesInner)]),
          () => ListBuilder<MenuSchedulesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(MenuItemAllOfVariants)]),
          () => ListBuilder<MenuItemAllOfVariants>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(MenuItemConfigComponentsInner)]),
          () => ListBuilder<MenuItemConfigComponentsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MenuItemConfig)]),
          () => ListBuilder<MenuItemConfig>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MenuMarginRow)]),
          () => ListBuilder<MenuMarginRow>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ModifierGroup)]),
          () => ListBuilder<ModifierGroup>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(ModifierGroupOptionsInner)]),
          () => ListBuilder<ModifierGroupOptionsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ModifierSelection)]),
          () => ListBuilder<ModifierSelection>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ModifierSelection)]),
          () => ListBuilder<ModifierSelection>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PlatformOrder)]),
          () => ListBuilder<PlatformOrder>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PlatformOrder)]),
          () => ListBuilder<PlatformOrder>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PlatformOrderItem)]),
          () => ListBuilder<PlatformOrderItem>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(PlatformOrderLineInput)]),
          () => ListBuilder<PlatformOrderLineInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PlatformReportRow)]),
          () => ListBuilder<PlatformReportRow>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PlatformSetting)]),
          () => ListBuilder<PlatformSetting>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(PlatformSettleOrderInput)]),
          () => ListBuilder<PlatformSettleOrderInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(PosCupLabelSettingsUpdateRequestFieldsEnum)
          ]),
          () => ListBuilder<PosCupLabelSettingsUpdateRequestFieldsEnum>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(PosPrinterStations200ResponseDataInner)]),
          () => ListBuilder<PosPrinterStations200ResponseDataInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(PosRecipeSaveRequestIngredientsInner)]),
          () => ListBuilder<PosRecipeSaveRequestIngredientsInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(PrintBlockOneOf4PartiesInner)]),
          () => ListBuilder<PrintBlockOneOf4PartiesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PrintJob)]),
          () => ListBuilder<PrintJob>())
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
          const FullType(
              BuiltList, const [const FullType(RecipeIngredientsInner)]),
          () => ListBuilder<RecipeIngredientsInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(RecipeOwnerVersionsInner)]),
          () => ListBuilder<RecipeOwnerVersionsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(StationRoute)]),
          () => ListBuilder<StationRoute>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(StockAlert)]),
          () => ListBuilder<StockAlert>())
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
              BuiltList, const [const FullType(MenuItemConfigComponentsInner)]),
          () => ListBuilder<MenuItemConfigComponentsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(WorkspaceLine)]),
          () => ListBuilder<WorkspaceLine>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(WorkspaceTotalsTaxesInner)]),
          () => ListBuilder<WorkspaceTotalsTaxesInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(int)]),
          () => MapBuilder<String, int>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenTicketItem)]),
          () => ListBuilder<KitchenTicketItem>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
