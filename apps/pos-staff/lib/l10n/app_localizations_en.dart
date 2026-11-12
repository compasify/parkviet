// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ParkViet Staff';

  @override
  String get welcomeTitle => 'Pair with your store';

  @override
  String get welcomeBody =>
      'Open Devices in the dashboard, create a pairing code, then scan its QR or type the server address and code.';

  @override
  String get welcomeScan => 'Scan pairing QR';

  @override
  String get welcomeManual => 'Type server address and code';

  @override
  String get revokedNotice =>
      'The server revoked or removed this device. Pair it again.';

  @override
  String get scanTitle => 'Scan pairing QR';

  @override
  String get scanHint => 'Point the camera at the QR on the manager\'s screen.';

  @override
  String get scanCameraUnavailable =>
      'The camera did not open. Allow camera access, or go back and type the code.';

  @override
  String get pairingWorking => 'Pairing…';

  @override
  String get manualTitle => 'Type server address';

  @override
  String get manualServerLabel => 'Server address';

  @override
  String get manualServerHint =>
      'http://192.168.1.10 or https://pos.example.com';

  @override
  String get manualCodeLabel => 'Pairing code';

  @override
  String get manualNameLabel => 'Device name';

  @override
  String get manualSubmit => 'Pair';

  @override
  String get pairingNotPairingCode => 'This is not a ParkViet pairing QR.';

  @override
  String get pairingUnsupportedVersion =>
      'This QR is from another version. Update the app.';

  @override
  String get pairingWrongKind => 'This QR is not for pairing a device.';

  @override
  String get pairingInvalidUrl =>
      'The server address is not valid. It must start with http:// or https://.';

  @override
  String get pairingInsecureUrl =>
      'http:// is only for a server on the shop network (IP 192.168.x.x, 10.x.x.x, 172.16–31.x.x or a .local name). A server on the internet must use https://.';

  @override
  String get pairingMissingCode => 'The pairing code is missing.';

  @override
  String get pairingCodeInvalid =>
      'The pairing code is wrong or expired. Create a new one.';

  @override
  String get failureTimeout =>
      'The server did not answer in time. Check the network and try again.';

  @override
  String get failureTls =>
      'The server\'s security certificate (HTTPS) is not trusted. Check the address, or ask the installer to check the certificate.';

  @override
  String get failureCleartext =>
      'This device blocks unencrypted connections (http://) to that address.';

  @override
  String get failureUnreachable =>
      'Cannot reach the server. Check the address and that this device is on the server\'s network.';

  @override
  String get failureUnauthorized =>
      'The server does not recognise this device or sign-in.';

  @override
  String get failureForbidden => 'This device or account may not do that.';

  @override
  String get failureNotFound => 'Not found on the server.';

  @override
  String get failureRateLimited =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String failureConflict(String reason) {
    return 'The server refused: $reason';
  }

  @override
  String failureServer(int status) {
    return 'The server had an error ($status). Try again later.';
  }

  @override
  String get failureUnexpected => 'Something unexpected went wrong. Try again.';

  @override
  String get pinIncorrect => 'Wrong PIN.';

  @override
  String get pinNotSet => 'No PIN set. Set one in the dashboard first.';

  @override
  String get pinLocked =>
      'Too many wrong PINs. Locked for 15 minutes on this device.';

  @override
  String get pinRateLimited =>
      'Too many wrong PINs on this device. Wait a moment.';

  @override
  String get offlineTitle => 'Server unreachable';

  @override
  String offlineBody(String serverUrl) {
    return 'This device is paired with $serverUrl but could not reach it.';
  }

  @override
  String get retry => 'Try again';

  @override
  String get staffPickerTitle => 'Pick your name';

  @override
  String get managerPickerTitle => 'Manager confirmation';

  @override
  String get staffPickerEmpty => 'No staff at this branch yet.';

  @override
  String pinTitle(String name) {
    return '$name\'s PIN';
  }

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinSubmit => 'Sign in';

  @override
  String get managerDenied => 'This person may not manage devices.';

  @override
  String get signOut => 'Sign out';

  @override
  String get manageTitle => 'Device information';

  @override
  String get manageDeviceName => 'Device name';

  @override
  String get manageMode => 'Mode';

  @override
  String get manageBranch => 'Branch';

  @override
  String get manageServer => 'Server';

  @override
  String get manageAppVersion => 'App version';

  @override
  String get manageEditorId => 'Installation id';

  @override
  String get manageClockOffset => 'Clock offset from server (seconds)';

  @override
  String get manageRevokeHint =>
      'Unpairing only removes the pairing from this device. To revoke it for good, use Devices in the dashboard.';

  @override
  String get manageUnpair => 'Unpair';

  @override
  String get manageUnpairConfirmTitle => 'Unpair this device?';

  @override
  String get manageUnpairConfirmBody =>
      'The device forgets the server and needs a new code to pair again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get modeWaiter => 'Waiter';

  @override
  String get modeKds => 'Kitchen display';

  @override
  String get modeExpo => 'Runner';

  @override
  String get modeKiosk => 'Kiosk';

  @override
  String get modePrintStation => 'Print station';

  @override
  String get modeOwner => 'Owner';

  @override
  String modePlaceholderBody(String mode) {
    return 'The $mode mode comes in a later update. This device is paired and connected.';
  }

  @override
  String get realtimeConnected => 'Online';

  @override
  String get realtimeConnecting => 'Connecting';

  @override
  String get realtimeDisconnected => 'Disconnected';

  @override
  String get realtimeRejected => 'Refused';

  @override
  String get realtimeIdle => 'Not connected';

  @override
  String get stationIosWarning =>
      'iPhone and iPad cannot run in the background: keep the app open and the screen on to print.';

  @override
  String stationServerError(String message) {
    return 'Cannot reach the server: $message';
  }

  @override
  String get stationPrinters => 'Printers';

  @override
  String get stationNoPrinters =>
      'No print jobs yet. Printers show here after the first job, or after a test print from the dashboard.';

  @override
  String get stationTestPrint => 'Test print';

  @override
  String get stationRecent => 'Recent jobs';

  @override
  String get stationNoJobs => 'No print jobs yet.';

  @override
  String get stationLocalTest => 'local test';

  @override
  String get stationPrinted => 'Printed';

  @override
  String stationFailed(String error) {
    return 'Error: $error';
  }

  @override
  String get stationTestTitle => 'TEST PRINT';

  @override
  String get stationTestSample =>
      'Vietnamese: Phở bò tái, cà phê sữa đá, bánh mì.';

  @override
  String get stationTestDone => 'Test page sent.';

  @override
  String get stationForegroundTitle => 'ParkViet print station';

  @override
  String get stationForegroundText => 'Receiving print jobs';

  @override
  String get kdsTabPriority => 'Priority';

  @override
  String get kdsTabByItem => 'By item';

  @override
  String get kdsTabByOrder => 'By table / number';

  @override
  String get kdsDone => 'Done (last 30 minutes)';

  @override
  String get kdsNothingOpen => 'Nothing to make.';

  @override
  String get kdsNothingDone => 'No ticket finished yet.';

  @override
  String get kdsStart => 'Start';

  @override
  String get kdsReady => 'Ready';

  @override
  String get kdsServe => 'Served';

  @override
  String get kdsRecall => 'Recall';

  @override
  String get kdsBump => 'Bump ticket';

  @override
  String get kdsServeOrder => 'Handed over';

  @override
  String kdsGuest(String name) {
    return 'Guest: $name';
  }

  @override
  String get kdsPlatformGrabfood => 'GRABFOOD';

  @override
  String get kdsPlatformShopeefood => 'SHOPEEFOOD';

  @override
  String kdsPickupCode(String code) {
    return 'Pickup: $code';
  }

  @override
  String kdsTicketNumber(int number) {
    return 'Ticket #$number';
  }

  @override
  String kdsOrder(String id) {
    return 'Order $id';
  }

  @override
  String kdsTickets(String numbers) {
    return 'Tickets $numbers';
  }

  @override
  String kdsNote(String note) {
    return 'Note: $note';
  }

  @override
  String kdsOffline(String time) {
    return 'Offline · last update $time';
  }

  @override
  String get kdsOfflineNever => 'Offline · board not loaded yet';

  @override
  String kdsActionFailed(String message) {
    return 'Could not change the item: $message';
  }

  @override
  String get kdsStationPick => 'Which station does this screen show?';

  @override
  String get kdsAllStations => 'All stations';

  @override
  String get kdsChangeStation => 'Change station';

  @override
  String get kdsNoStations =>
      'This branch has no kitchen station yet. Add one in the admin dashboard, Kitchen & bar.';

  @override
  String get kdsSoldOut => 'Sold out';

  @override
  String get kdsSoldOutTitle => 'Sold out today';

  @override
  String get kdsSoldOutWho => 'Who is marking it?';

  @override
  String kdsPinFor(String name) {
    return 'PIN for $name';
  }

  @override
  String get kdsConfirm => 'Confirm';

  @override
  String get kdsStatusNew => 'New';

  @override
  String get kdsStatusPreparing => 'Preparing';

  @override
  String get kdsStatusReady => 'Ready';

  @override
  String get kdsStatusServed => 'Served';

  @override
  String get kdsStatusVoided => 'Voided';

  @override
  String get kdsModeCounter => 'Counter';

  @override
  String get kdsModeDineIn => 'Dine in';

  @override
  String get kdsModeTakeaway => 'Takeaway';

  @override
  String get kdsModeDelivery => 'Delivery';

  @override
  String get kdsDoneHint =>
      'Hold an item to call back a dish that is ready or served.';

  @override
  String kdsRecalled(int count) {
    return 'Recalled $count×';
  }

  @override
  String get kdsAllDayOne => 'Ready 1';

  @override
  String kdsAllDayAll(int count) {
    return 'All ready ($count)';
  }

  @override
  String get kdsServiceModeAll => 'Every service';

  @override
  String get kdsServiceModeFilter => 'Filter by service';

  @override
  String get kdsStationExpo => 'Pass (expo)';

  @override
  String get kdsStationPickHint =>
      'Pick one or more stations. The choice stays on this device.';

  @override
  String kdsStationShow(int count) {
    return 'Show $count stations';
  }

  @override
  String get expoNothingReady => 'Nothing is waiting at the pass.';

  @override
  String get expoServeAll => 'Serve whole order';

  @override
  String get modifierVariant => 'Size / kind';

  @override
  String get modifierNote => 'Note for the kitchen';

  @override
  String modifierAdd(String amount) {
    return 'Add · $amount';
  }

  @override
  String modifierPickExactly(int count) {
    return 'Pick $count';
  }

  @override
  String modifierPickBetween(int min, int max) {
    return 'Pick $min to $max';
  }

  @override
  String modifierPickUpTo(int max) {
    return 'Pick up to $max';
  }

  @override
  String get voidReasonChangedMind => 'Guest changed their mind';

  @override
  String get voidReasonSoldOut => 'Sold out';

  @override
  String get voidReasonMistake => 'Entered by mistake';

  @override
  String get voidReasonSpoiled => 'Spoiled';

  @override
  String get voidReasonOther => 'Other (say why)';

  @override
  String get waiterAllAreas => 'All areas';

  @override
  String get waiterFilterAll => 'All';

  @override
  String get waiterFilterFree => 'Free';

  @override
  String get waiterFilterSeated => 'Seated';

  @override
  String get waiterFilterWaiting => 'Waiting for dishes';

  @override
  String get waiterFilterPayment => 'Payment requested';

  @override
  String get waiterFilterMine => 'Mine';

  @override
  String get waiterNoTables => 'No tables.';

  @override
  String get waiterStateFree => 'Free';

  @override
  String get waiterStateSeated => 'Seated';

  @override
  String get waiterStateOrdered => 'Ordered';

  @override
  String get waiterStateWaitingLong => 'Waiting long';

  @override
  String get waiterStatePayment => 'Payment requested';

  @override
  String get waiterStatePrebilled => 'Prebill printed';

  @override
  String get waiterStateCleaning => 'Cleaning';

  @override
  String get waiterStateOut => 'Out of service';

  @override
  String waiterGuests(int count) {
    return '$count guests';
  }

  @override
  String waiterSeatedMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String waiterPendingItems(int count) {
    return '$count dishes waiting';
  }

  @override
  String get waiterPaymentRequested => 'Payment requested';

  @override
  String waiterOrders(int count) {
    return '$count orders';
  }

  @override
  String waiterPickOrder(String table) {
    return '$table: pick an order';
  }

  @override
  String waiterOrderLetter(String letter) {
    return 'Order $letter';
  }

  @override
  String get waiterSecondOrder => 'Open another order on this table';

  @override
  String get waiterPin => 'Pin table (hear when dishes are ready)';

  @override
  String get waiterUnpin => 'Unpin table';

  @override
  String get waiterFollowTitle => 'Ready alerts';

  @override
  String get waiterFollowHint =>
      'By default: tables you ordered for and tables you pinned.';

  @override
  String get waiterFollowMine => 'Only my tables';

  @override
  String waiterFollowArea(String area) {
    return 'Every table in $area';
  }

  @override
  String waiterReadyCount(int count) {
    return '$count dishes ready, tap to open the table';
  }

  @override
  String waiterReadyNotice(String table, String name, String quantity) {
    return '$table: $name ×$quantity is ready';
  }

  @override
  String get waiterClose => 'Close';

  @override
  String waiterGuestsFor(String table) {
    return 'Guests · $table';
  }

  @override
  String waiterCapacity(int count) {
    return 'Seats $count';
  }

  @override
  String get waiterOpenTable => 'Open';

  @override
  String waiterOrderFor(String table) {
    return 'Order · $table';
  }

  @override
  String get waiterSearch => 'Search dishes';

  @override
  String get waiterAllCategories => 'All';

  @override
  String get waiterNoDishes => 'No dishes.';

  @override
  String get waiterSoldOutLabel => 'Sold out';

  @override
  String waiterCart(int count, String amount) {
    return '$count items · $amount';
  }

  @override
  String get waiterAddToOrder => 'Add to order';

  @override
  String get waiterAddAndSend => 'Add and send';

  @override
  String get waiterAdded => 'Added to the order.';

  @override
  String get waiterAddedAndSent => 'Added and sent to the kitchen.';

  @override
  String get waiterSent => 'Sent to the kitchen.';

  @override
  String get waiterOrderDishes => 'Order';

  @override
  String get waiterSend => 'Send';

  @override
  String waiterSendCount(int count) {
    return 'Send ($count)';
  }

  @override
  String waiterSubtotal(String amount) {
    return 'Subtotal $amount';
  }

  @override
  String get waiterEmptyOrder => 'No dishes yet. Tap \"Order\".';

  @override
  String waiterLineUnsent(String count) {
    return '$count not sent';
  }

  @override
  String waiterLineNew(String count) {
    return '$count new';
  }

  @override
  String waiterLinePreparing(String count) {
    return '$count cooking';
  }

  @override
  String waiterLineReady(String count) {
    return '$count ready';
  }

  @override
  String waiterLineServed(String count) {
    return '$count served';
  }

  @override
  String get waiterVoidSent => 'Void sent dishes';

  @override
  String get waiterRemoveUnsent => 'Remove (not sent)';

  @override
  String get waiterVoided => 'Dish voided.';

  @override
  String waiterVoidTitle(String name) {
    return 'Void $name';
  }

  @override
  String waiterVoidSentCount(int count) {
    return 'The kitchen has $count.';
  }

  @override
  String get waiterVoidNote => 'Note';

  @override
  String get waiterVoidNoteRequired => 'Reason (required)';

  @override
  String get waiterVoidConfirm => 'Void';

  @override
  String get waiterWaitingApproval =>
      'Waiting for a manager. The code fills in when a manager approves this order, or type it below.';

  @override
  String get waiterApprovalCode => 'Approval code';

  @override
  String get waiterRequestPayment => 'Request payment';

  @override
  String get waiterPaymentRequestSent => 'The cashier is told.';

  @override
  String get waiterMove => 'Move table';

  @override
  String get waiterMerge => 'Merge tables';

  @override
  String get waiterMoveTo => 'Move to a free table';

  @override
  String get waiterMergeInto => 'Merge into the order of';

  @override
  String get waiterMoved => 'Table moved.';

  @override
  String get waiterMerged => 'Tables merged.';

  @override
  String get waiterChecklist => 'Print checklist';

  @override
  String get waiterPrebill => 'Print prebill';

  @override
  String waiterPrintQueued(String printer) {
    return 'Sent to $printer.';
  }

  @override
  String waiterPrinted(String printer) {
    return 'Printed on $printer.';
  }

  @override
  String waiterPrintFailed(String error) {
    return 'Could not print: $error';
  }

  @override
  String get waiterNoPrinter => 'No printer for this document';

  @override
  String get waiterLineChanged =>
      'Someone else just changed this dish. The order is reloaded.';

  @override
  String get waiterSnapshotLocked =>
      'The order is being paid and cannot change. The order is reloaded.';

  @override
  String get waiterLeaseBusy =>
      'Another device is editing this order. Try again shortly.';

  @override
  String get waiterWorkspaceClosed => 'The order is closed.';

  @override
  String get waiterSoldOut => 'This dish is sold out.';

  @override
  String get waiterTableOccupied => 'The table is taken.';

  @override
  String get waiterTableUnavailable => 'The table is not in service.';

  @override
  String get waiterGuestCountInvalid =>
      'That guest count does not fit this table.';

  @override
  String get waiterModifierInvalid =>
      'The options are not valid. Open the dish again.';

  @override
  String get waiterVoidQuantityInvalid => 'The quantity to void is not valid.';

  @override
  String get waiterVoidReasonInvalid =>
      'Pick a reason, or write one for \"Other\".';

  @override
  String get waiterForbidden => 'You may not do that on the waiter device.';

  @override
  String get checklistTitle => 'Device paired';

  @override
  String checklistIntro(String branch) {
    return 'This device is paired with $branch. Check the items below before using it.';
  }

  @override
  String get checklistStation => 'Kitchen station';

  @override
  String checklistStationOk(String name) {
    return 'Chosen: $name';
  }

  @override
  String get checklistStationMissing =>
      'No station chosen yet. Pick one on the kitchen screen after starting.';

  @override
  String get checklistPrinter => 'Station printer';

  @override
  String checklistPrinterOk(String name) {
    return 'Received: $name';
  }

  @override
  String get checklistPrinterMissing =>
      'The station has no printer; tickets only show on screen. Assign one on the branch page, Kitchen & bar tab.';

  @override
  String get checklistStaff => 'Staff with a PIN';

  @override
  String checklistStaffOk(int count) {
    return '$count people can sign in with a PIN';
  }

  @override
  String get checklistStaffMissing =>
      'Nobody has a PIN yet. A manager sets staff PINs on the admin site.';

  @override
  String get checklistNothing => 'This mode needs nothing else set up.';

  @override
  String get checklistStart => 'Start';

  @override
  String get courseNone => 'No course';

  @override
  String get courseStarter => 'Starter';

  @override
  String get courseMain => 'Main';

  @override
  String get courseDessert => 'Dessert';

  @override
  String courseNumber(int number) {
    return 'Course $number';
  }

  @override
  String get courseHold => 'Hold until fired';

  @override
  String get courseHeldTitle => 'Held, waiting to be fired';

  @override
  String courseFire(String course, int count) {
    return 'Fire $course ($count dishes)';
  }

  @override
  String courseFired(String course) {
    return 'Sent to the kitchen: $course';
  }

  @override
  String get seatLabel => 'Seat';

  @override
  String get seatShared => 'Shared';

  @override
  String seatNumber(int seat) {
    return 'Seat $seat';
  }

  @override
  String get expoHeldTitle => 'Waiting to be fired';

  @override
  String get expoReadyTitle => 'Ready, to take out';

  @override
  String get expoAllAreas => 'All areas';

  @override
  String expoArea(int number) {
    return 'Area $number';
  }

  @override
  String get ownerReservationsTitle => 'Today\'s bookings';

  @override
  String get ownerNoReservations => 'No bookings today yet.';

  @override
  String ownerDeposit(String amount, String status) {
    return 'Deposit $amount · $status';
  }

  @override
  String get ownerRefund => 'Refund deposit';

  @override
  String get ownerForfeit => 'Keep deposit';

  @override
  String ownerConfirmRefund(String amount, String name) {
    return 'Refund $amount to $name?';
  }

  @override
  String ownerConfirmForfeit(String amount, String name) {
    return 'Keep the $amount deposit of $name? It becomes a taxed holding-fee sale.';
  }

  @override
  String get ownerConfirm => 'Confirm';

  @override
  String get ownerKeep => 'Not now';

  @override
  String get ownerRefunded => 'The deposit was refunded.';

  @override
  String get ownerForfeited => 'The deposit was kept.';

  @override
  String get reservationBooked => 'Booked';

  @override
  String get reservationSeated => 'Seated';

  @override
  String get reservationCompleted => 'Done';

  @override
  String get reservationNoShow => 'No-show';

  @override
  String get reservationCanceled => 'Canceled';

  @override
  String get depositHeld => 'held';

  @override
  String get depositApplied => 'taken off the bill';

  @override
  String get depositRefunded => 'refunded';

  @override
  String get depositForfeited => 'kept';

  @override
  String get waiterTabsTitle => 'Open tabs';

  @override
  String get waiterTabOpen => 'Open tab';

  @override
  String get waiterTabSearch => 'Guest name, table or tab number';

  @override
  String get waiterTabsNone => 'No tab is open.';

  @override
  String get waiterTabsNoMatch => 'No tab matches.';

  @override
  String waiterTabOpenedAt(String time) {
    return 'Opened $time';
  }

  @override
  String get waiterTabName => 'Guest name or description';

  @override
  String get waiterTabNameTaken => 'An open tab already has this name.';

  @override
  String get waiterTabNameInvalid => 'Enter a tab name (up to 60 characters).';

  @override
  String get waiterBottleTitle => 'Pour a kept bottle';

  @override
  String get waiterBottleCode => 'Bottle code';

  @override
  String get waiterBottleNotFound => 'No kept bottle has this code.';

  @override
  String waiterBottleLevel(int level) {
    return '$level% left';
  }

  @override
  String waiterBottleNewLevel(int level) {
    return 'Level after the pour: $level%';
  }

  @override
  String get waiterBottleMl => 'Poured ml (optional)';

  @override
  String get waiterBottlePour => 'Pour';

  @override
  String waiterBottlePoured(int level) {
    return 'Poured; $level% left.';
  }

  @override
  String get waiterBottleClosed => 'This bottle is no longer kept.';

  @override
  String get waiterBottleLevelRaised =>
      'A pour never raises the level; a manager corrects a mistake.';

  @override
  String get waiterRoomsTitle => 'Rooms';

  @override
  String get waiterRoomsNone => 'This branch has no rooms or billiard tables.';

  @override
  String get waiterStatePlaying => 'Clock running';

  @override
  String get waiterStateEndingSoon => 'Ending soon';

  @override
  String get waiterClockStart => 'Start the clock';

  @override
  String get waiterClockStop => 'Stop the clock';

  @override
  String waiterClockStopConfirm(String room) {
    return 'Stop the clock of $room? The time is billed on the server\'s clock.';
  }

  @override
  String get waiterClockMove => 'Move room';

  @override
  String waiterClockMoveTo(String room) {
    return 'Move $room to';
  }

  @override
  String get waiterClockMoveNone => 'No free room to move to.';

  @override
  String get waiterClockOpenOrder => 'Open the room\'s order';

  @override
  String waiterClockQuote(String amount) {
    return 'So far $amount';
  }

  @override
  String waiterClockStopped(String amount) {
    return 'Clock stopped, time charge $amount.';
  }

  @override
  String get waiterClockRunning => 'This room\'s clock is running.';

  @override
  String get waiterClockNoRatePlan =>
      'This room has no rate plan. Ask a manager to add one.';

  @override
  String get waiterClockPickOrder =>
      'This room has several open orders; pick the one to bill.';

  @override
  String get waiterClockAlreadyStopped => 'This room\'s clock has stopped.';

  @override
  String get waiterClockPause => 'Pause the clock';

  @override
  String get waiterClockResume => 'Resume the clock';

  @override
  String get waiterClockPaused => 'Paused';

  @override
  String get waiterClockAlreadyPaused =>
      'This room\'s clock is already paused.';

  @override
  String get waiterClockNotPaused => 'This room\'s clock is not paused.';

  @override
  String get waiterClockLongPause =>
      'Paused too long: a manager approves resuming at the counter.';

  @override
  String waiterClockPackageLeft(int minutes) {
    return '$minutes min left in the package';
  }

  @override
  String get waiterServeRoom => 'I serve this room';

  @override
  String waiterServingRoom(String room) {
    return 'You now serve $room.';
  }

  @override
  String get waiterAttendantBusy => 'You already serve another room.';

  @override
  String waiterAlertEndingSoon(String room) {
    return '$room has 10 minutes left';
  }

  @override
  String waiterAlertEndedPackage(String room) {
    return '$room has used its package';
  }

  @override
  String waiterAlertPauseTooLong(String room) {
    return '$room has been paused too long';
  }
}
