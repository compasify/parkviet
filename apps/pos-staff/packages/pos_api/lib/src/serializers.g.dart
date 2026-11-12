// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add($KitchenStationInput.serializer)
      ..add($MealAccount.serializer)
      ..add($MenuItemConfig.serializer)
      ..add($StationRouteInput.serializer)
      ..add(AppendItem.serializer)
      ..add(AppendItemsInput.serializer)
      ..add(AppendItemsMeta.serializer)
      ..add(AppendItemsResult.serializer)
      ..add(Approval.serializer)
      ..add(ApprovalRevision.serializer)
      ..add(Area.serializer)
      ..add(AreaInput.serializer)
      ..add(AreaList.serializer)
      ..add(AreaResult.serializer)
      ..add(AreaStatusEnum.serializer)
      ..add(AvailableResource.serializer)
      ..add(AvailableResourceKindEnum.serializer)
      ..add(BottleKeep.serializer)
      ..add(BottleKeepActor.serializer)
      ..add(BottleKeepCustomer.serializer)
      ..add(BottleKeepEvent.serializer)
      ..add(BottleKeepEventKindEnum.serializer)
      ..add(BottleKeepList.serializer)
      ..add(BottleKeepResult.serializer)
      ..add(BottleKeepStatusEnum.serializer)
      ..add(BuffetTier.serializer)
      ..add(BuffetTierItem.serializer)
      ..add(BuffetTierList.serializer)
      ..add(BuffetTierStatusEnum.serializer)
      ..add(BusOperatorRef.serializer)
      ..add(CallBoard.serializer)
      ..add(CallBoardPreparingInner.serializer)
      ..add(CallBoardReadyInner.serializer)
      ..add(CatalogItem.serializer)
      ..add(ChecklistInput.serializer)
      ..add(ChecklistOutcome.serializer)
      ..add(ChecklistResult.serializer)
      ..add(Context.serializer)
      ..add(ContextAdministration.serializer)
      ..add(ContextBranch.serializer)
      ..add(ContextEinvoiceTypeEnum.serializer)
      ..add(ContextStaff.serializer)
      ..add(ContextStore.serializer)
      ..add(CourseLabel.serializer)
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
      ..add(EditUnsentLineInput.serializer)
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
      ..add(HardwareCheck.serializer)
      ..add(HardwareCheckKeyEnum.serializer)
      ..add(HardwareCheckStatusEnum.serializer)
      ..add(HardwareDevice.serializer)
      ..add(HardwareDeviceModeEnum.serializer)
      ..add(HardwareDisplays.serializer)
      ..add(HardwareEinvoice.serializer)
      ..add(HardwareEinvoiceTypeEnum.serializer)
      ..add(HardwarePrinter.serializer)
      ..add(HardwareServer.serializer)
      ..add(HardwareStation.serializer)
      ..add(HardwareStationKindEnum.serializer)
      ..add(HardwareStatus.serializer)
      ..add(IngredientUsageRow.serializer)
      ..add(KitchenAllDayBumpInput.serializer)
      ..add(KitchenAllDayRow.serializer)
      ..add(KitchenBoard.serializer)
      ..add(KitchenBoardResult.serializer)
      ..add(KitchenExpoItem.serializer)
      ..add(KitchenExpoOrder.serializer)
      ..add(KitchenHeldCourse.serializer)
      ..add(KitchenHeldLine.serializer)
      ..add(KitchenHistory.serializer)
      ..add(KitchenHistoryEntry.serializer)
      ..add(KitchenHistoryEntryKindEnum.serializer)
      ..add(KitchenHistoryItem.serializer)
      ..add(KitchenHistoryResult.serializer)
      ..add(KitchenMenuItem.serializer)
      ..add(KitchenOrderServedResult.serializer)
      ..add(KitchenOrderServedResultData.serializer)
      ..add(KitchenSendInput.serializer)
      ..add(KitchenSendMeta.serializer)
      ..add(KitchenSendResult.serializer)
      ..add(KitchenSendSummary.serializer)
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
      ..add(KitchenTicketItemModifier.serializer)
      ..add(KitchenTicketItemModifiersInner.serializer)
      ..add(KitchenTicketItemStatusEnum.serializer)
      ..add(KitchenTicketKindEnum.serializer)
      ..add(KitchenTicketList.serializer)
      ..add(KitchenTicketResult.serializer)
      ..add(KitchenTicketStationKindEnum.serializer)
      ..add(KitchenVoid.serializer)
      ..add(KitchenVoidInput.serializer)
      ..add(KitchenVoidMeta.serializer)
      ..add(KitchenVoidResult.serializer)
      ..add(LeaseClaimInput.serializer)
      ..add(LineComponent.serializer)
      ..add(LineKitchenStatus.serializer)
      ..add(LineModifier.serializer)
      ..add(MealAccountPayModeEnum.serializer)
      ..add(MealAccountStatusEnum.serializer)
      ..add(MealResolve.serializer)
      ..add(MealResolveResult.serializer)
      ..add(MealSplitPlan.serializer)
      ..add(MealSponsorRef.serializer)
      ..add(MealStatus.serializer)
      ..add(MealSwipe.serializer)
      ..add(MealSwipeInput.serializer)
      ..add(MealSwipeInputInputMethodEnum.serializer)
      ..add(MealSwipeResult.serializer)
      ..add(MealSwipeResultEnum.serializer)
      ..add(MealWalletPay.serializer)
      ..add(MealWalletPayInput.serializer)
      ..add(MealWalletPayResult.serializer)
      ..add(MealWindow.serializer)
      ..add(Menu.serializer)
      ..add(MenuAvailability.serializer)
      ..add(MenuCategory.serializer)
      ..add(MenuItem.serializer)
      ..add(MenuItemAllOfVariants.serializer)
      ..add(MenuItemConfigComponentsInner.serializer)
      ..add(MenuItemConfigKindEnum.serializer)
      ..add(MenuItemsMeta.serializer)
      ..add(MenuMarginRow.serializer)
      ..add(MenuSchedulesInner.serializer)
      ..add(MenuTaxDefaults.serializer)
      ..add(ModifierGroup.serializer)
      ..add(ModifierGroupOptionsInner.serializer)
      ..add(ModifierPick.serializer)
      ..add(ModifierSelection.serializer)
      ..add(PaymentRequest.serializer)
      ..add(PaymentRequestInput.serializer)
      ..add(PaymentRequestResolveInput.serializer)
      ..add(PaymentRequestResolveInputStatusEnum.serializer)
      ..add(PaymentRequestStatusEnum.serializer)
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
      ..add(PosHardwareStatus200Response.serializer)
      ..add(PosKitchenOrders200Response.serializer)
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
      ..add(PrebillInput.serializer)
      ..add(PrebillInputUnmaskEnum.serializer)
      ..add(PrebillOutcome.serializer)
      ..add(PrebillResult.serializer)
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
      ..add(ReadyFeed.serializer)
      ..add(ReadyFeedItem.serializer)
      ..add(ReadyFeedItemStatusEnum.serializer)
      ..add(ReadyFeedResult.serializer)
      ..add(RealtimeEvent.serializer)
      ..add(RealtimeEventEventEnum.serializer)
      ..add(Recipe.serializer)
      ..add(RecipeIngredientsInner.serializer)
      ..add(RecipeOwner.serializer)
      ..add(RecipeOwnerOwnerTypeEnum.serializer)
      ..add(RecipeOwnerVersionsInner.serializer)
      ..add(Reservation.serializer)
      ..add(ReservationAvailabilityResult.serializer)
      ..add(ReservationAvailabilityResultMeta.serializer)
      ..add(ReservationCancelInput.serializer)
      ..add(ReservationCancelInputStatusEnum.serializer)
      ..add(ReservationDeposit.serializer)
      ..add(ReservationDepositKindEnum.serializer)
      ..add(ReservationDepositResolveInput.serializer)
      ..add(ReservationDepositStatusEnum.serializer)
      ..add(ReservationInput.serializer)
      ..add(ReservationInputSource_Enum.serializer)
      ..add(ReservationList.serializer)
      ..add(ReservationListMeta.serializer)
      ..add(ReservationResult.serializer)
      ..add(ReservationSeat.serializer)
      ..add(ReservationSeatInput.serializer)
      ..add(ReservationSeatResult.serializer)
      ..add(ReservationSource_Enum.serializer)
      ..add(ReservationStatusEnum.serializer)
      ..add(Resource.serializer)
      ..add(ResourceBoard.serializer)
      ..add(ResourceBoardArea.serializer)
      ..add(ResourceBoardOrder.serializer)
      ..add(ResourceBoardOrderOperationalStatusEnum.serializer)
      ..add(ResourceBoardResult.serializer)
      ..add(ResourceBoardTile.serializer)
      ..add(ResourceBoardTileKindEnum.serializer)
      ..add(ResourceBoardTileManualStatusEnum.serializer)
      ..add(ResourceBoardTileShapeEnum.serializer)
      ..add(ResourceBoardTileStateEnum.serializer)
      ..add(ResourceInput.serializer)
      ..add(ResourceInputKindEnum.serializer)
      ..add(ResourceInputShapeEnum.serializer)
      ..add(ResourceKindEnum.serializer)
      ..add(ResourceList.serializer)
      ..add(ResourceManualStatusEnum.serializer)
      ..add(ResourceManualStatusInput.serializer)
      ..add(ResourceManualStatusInputManualStatusEnum.serializer)
      ..add(ResourceNextReservation.serializer)
      ..add(ResourceRef.serializer)
      ..add(ResourceRefKindEnum.serializer)
      ..add(ResourceResult.serializer)
      ..add(ResourceShapeEnum.serializer)
      ..add(ResourceStatusEnum.serializer)
      ..add(ServiceChargeWaiveInput.serializer)
      ..add(StaffRef.serializer)
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
      ..add(TableMergeInput.serializer)
      ..add(TableMoveInput.serializer)
      ..add(TableOpenInput.serializer)
      ..add(TablePinInput.serializer)
      ..add(TablePins.serializer)
      ..add(TablePinsResult.serializer)
      ..add(TableSettings.serializer)
      ..add(TableSettingsInput.serializer)
      ..add(TableSettingsInputCourseLabelsInner.serializer)
      ..add(TableSettingsInputServiceChargeAppliesToEnum.serializer)
      ..add(TableSettingsResult.serializer)
      ..add(TableSettingsServiceChargeAppliesToEnum.serializer)
      ..add(TableSplitInput.serializer)
      ..add(TableSplitInputByEnum.serializer)
      ..add(TableSplitOrders.serializer)
      ..add(TableSplitResult.serializer)
      ..add(TableTaxCategory.serializer)
      ..add(TaxRow.serializer)
      ..add(TipSplitRule.serializer)
      ..add(TipSplitRuleModeEnum.serializer)
      ..add(VehicleCommissionSnapshot.serializer)
      ..add(VehicleType.serializer)
      ..add(VehicleVisit.serializer)
      ..add(VehicleVisitAdjustInput.serializer)
      ..add(VehicleVisitList.serializer)
      ..add(VehicleVisitOpenInput.serializer)
      ..add(VehicleVisitPayInput.serializer)
      ..add(VehicleVisitPayInputPayoutMethodEnum.serializer)
      ..add(VehicleVisitPayoutMethodEnum.serializer)
      ..add(VehicleVisitPayoutStatusEnum.serializer)
      ..add(VehicleVisitResult.serializer)
      ..add(VehicleVisitStatusEnum.serializer)
      ..add(VehicleVisitUpdateInput.serializer)
      ..add(VehicleVisitVoidInput.serializer)
      ..add(VehicleVisitWarningsEnum.serializer)
      ..add(Workspace.serializer)
      ..add(WorkspaceCreateInput.serializer)
      ..add(WorkspaceCreateInputServiceModeEnum.serializer)
      ..add(WorkspaceDrinkCredit.serializer)
      ..add(WorkspaceLine.serializer)
      ..add(WorkspaceLineCourseStatusEnum.serializer)
      ..add(WorkspaceLineKindEnum.serializer)
      ..add(WorkspaceMeal.serializer)
      ..add(WorkspaceMealResult.serializer)
      ..add(WorkspaceMinimumSpend.serializer)
      ..add(WorkspacePageMeta.serializer)
      ..add(WorkspacePrebill.serializer)
      ..add(WorkspacePrebillStatusEnum.serializer)
      ..add(WorkspaceReservation.serializer)
      ..add(WorkspaceResult.serializer)
      ..add(WorkspaceServiceCharge.serializer)
      ..add(WorkspaceServiceModeEnum.serializer)
      ..add(WorkspaceSummary.serializer)
      ..add(WorkspaceSummaryList.serializer)
      ..add(WorkspaceTotals.serializer)
      ..add(WorkspaceTotalsTaxesInner.serializer)
      ..add(WorkspaceVehicleVisitInput.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(AppendItem)]),
          () => ListBuilder<AppendItem>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Area)]),
          () => ListBuilder<Area>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(AvailableResource)]),
          () => ListBuilder<AvailableResource>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(BottleKeep)]),
          () => ListBuilder<BottleKeep>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(BottleKeepEvent)]),
          () => ListBuilder<BottleKeepEvent>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(BuffetTier)]),
          () => ListBuilder<BuffetTier>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(BuffetTierItem)]),
          () => ListBuilder<BuffetTierItem>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject)
            ])
          ]),
          () => ListBuilder<BuiltMap<String, JsonObject?>>())
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
          const FullType(BuiltList, const [const FullType(CourseLabel)]),
          () => ListBuilder<CourseLabel>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(TableSettingsServiceChargeAppliesToEnum)]),
          () => ListBuilder<TableSettingsServiceChargeAppliesToEnum>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TableTaxCategory)]),
          () => ListBuilder<TableTaxCategory>())
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
          const FullType(BuiltList, const [const FullType(HardwareCheck)]),
          () => ListBuilder<HardwareCheck>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(HardwarePrinter)]),
          () => ListBuilder<HardwarePrinter>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(HardwareStation)]),
          () => ListBuilder<HardwareStation>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(HardwareDevice)]),
          () => ListBuilder<HardwareDevice>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(IngredientUsageRow)]),
          () => ListBuilder<IngredientUsageRow>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenHeldLine)]),
          () => ListBuilder<KitchenHeldLine>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(KitchenHistoryEntry)]),
          () => ListBuilder<KitchenHistoryEntry>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenHistoryItem)]),
          () => ListBuilder<KitchenHistoryItem>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenMenuItem)]),
          () => ListBuilder<KitchenMenuItem>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenSendSummary)]),
          () => ListBuilder<KitchenSendSummary>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(WorkspaceLine)]),
          () => ListBuilder<WorkspaceLine>())
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
          const FullType(BuiltList, const [const FullType(KitchenAllDayRow)]),
          () => ListBuilder<KitchenAllDayRow>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenExpoOrder)]),
          () => ListBuilder<KitchenExpoOrder>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenHeldCourse)]),
          () => ListBuilder<KitchenHeldCourse>())
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
          const FullType(
              BuiltList, const [const FullType(KitchenTicketItemModifier)]),
          () => ListBuilder<KitchenTicketItemModifier>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(KitchenTicketItemModifier)]),
          () => ListBuilder<KitchenTicketItemModifier>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
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
          const FullType(BuiltList, const [const FullType(MealAccount)]),
          () => ListBuilder<MealAccount>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MealWindow)]),
          () => ListBuilder<MealWindow>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MealWindow)]),
          () => ListBuilder<MealWindow>())
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
          const FullType(BuiltList, const [const FullType(ModifierPick)]),
          () => ListBuilder<ModifierPick>())
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
          const FullType(BuiltList, const [const FullType(ReadyFeedItem)]),
          () => ListBuilder<ReadyFeedItem>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(RecipeIngredientsInner)]),
          () => ListBuilder<RecipeIngredientsInner>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(RecipeOwnerVersionsInner)]),
          () => ListBuilder<RecipeOwnerVersionsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Reservation)]),
          () => ListBuilder<Reservation>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ReservationDeposit)]),
          () => ListBuilder<ReservationDeposit>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Resource)]),
          () => ListBuilder<Resource>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ResourceBoardArea)]),
          () => ListBuilder<ResourceBoardArea>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ResourceBoardTile)]),
          () => ListBuilder<ResourceBoardTile>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ResourceBoardOrder)]),
          () => ListBuilder<ResourceBoardOrder>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ResourceRef)]),
          () => ListBuilder<ResourceRef>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ReservationDeposit)]),
          () => ListBuilder<ReservationDeposit>())
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
              BuiltMap, const [const FullType(String), const FullType(bool)]),
          () => MapBuilder<String, bool>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ContextBranch)]),
          () => ListBuilder<ContextBranch>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(TableSettingsInputServiceChargeAppliesToEnum)
          ]),
          () => ListBuilder<TableSettingsInputServiceChargeAppliesToEnum>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(TableSettingsInputCourseLabelsInner)]),
          () => ListBuilder<TableSettingsInputCourseLabelsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(VehicleVisit)]),
          () => ListBuilder<VehicleVisit>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(VehicleVisitWarningsEnum)]),
          () => ListBuilder<VehicleVisitWarningsEnum>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Workspace)]),
          () => ListBuilder<Workspace>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(WorkspaceSummary)]),
          () => ListBuilder<WorkspaceSummary>())
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
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(int)]),
          () => MapBuilder<String, int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(KitchenExpoItem)]),
          () => ListBuilder<KitchenExpoItem>())
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
