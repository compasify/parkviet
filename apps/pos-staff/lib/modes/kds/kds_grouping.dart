import 'package:pos_api/pos_api.dart';

/// How long a ticket has waited, against its station's thresholds.
enum TicketUrgency { normal, warn, late }

const _openStatuses = {KitchenTicketItemStatusEnum.new_, KitchenTicketItemStatusEnum.preparing};

bool isOpen(KitchenTicketItem item) => _openStatuses.contains(item.status);

TicketUrgency urgencyOf(KitchenTicket ticket, KitchenStation? station, DateTime now) {
  final waited = now.difference(ticket.sentAt);
  final late = Duration(minutes: station?.lateAfterMinutes ?? 15);
  final warn = Duration(minutes: station?.warnAfterMinutes ?? 8);
  if (waited >= late) return TicketUrgency.late;
  if (waited >= warn) return TicketUrgency.warn;
  return TicketUrgency.normal;
}

/// mm:ss up to an hour, then h:mm:ss. Never negative.
String elapsedLabel(DateTime from, DateTime now) {
  final waited = now.difference(from);
  final seconds = waited.isNegative ? 0 : waited.inSeconds;
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  String two(int value) => value.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// '2.0' as 2, '1.5' as 1.5.
String quantityLabel(String quantity) {
  final value = num.tryParse(quantity);
  if (value == null) return quantity;
  return value == value.truncate() ? value.truncate().toString() : value.toString();
}

/// The options of an item as the kitchen reads them: "Ít đá, Trân châu x2".
String modifiersLabel(KitchenTicketItem item) => item.modifiers
    .map((modifier) => modifier.quantity > 1 ? '${modifier.name} x${modifier.quantity}' : modifier.name)
    .join(', ');

/// The options of an all-day row, read the same way.
String allDayModifiersLabel(KitchenAllDayRow row) => row.modifiers
    .map((modifier) => modifier.quantity > 1 ? '${modifier.name} x${modifier.quantity}' : modifier.name)
    .join(', ');

/// One dish across every open ticket: what to make in a batch.
class ItemTally {
  ItemTally({required this.name, required this.options});

  final String name;
  final String options;
  num quantity = 0;
  final items = <KitchenTicketItem>[];
  final ticketSequences = <int>{};
}

/// Open items grouped by name and options, the largest batch first.
List<ItemTally> tallyByItem(Iterable<KitchenTicket> tickets) {
  final tallies = <String, ItemTally>{};
  for (final ticket in tickets) {
    for (final item in ticket.items.where(isOpen)) {
      final options = modifiersLabel(item);
      final tally = tallies.putIfAbsent('${item.name}\u0000$options', () => ItemTally(name: item.name, options: options));
      tally
        ..quantity += num.tryParse(item.quantity) ?? 0
        ..items.add(item)
        ..ticketSequences.add(ticket.sequence);
    }
  }
  return tallies.values.toList()
    ..sort((a, b) {
      final byQuantity = b.quantity.compareTo(a.quantity);
      return byQuantity != 0 ? byQuantity : a.name.compareTo(b.name);
    });
}

/// The tickets of one order: a table, a call number, or the order itself.
class OrderGroup {
  OrderGroup({required this.workspaceId, required this.label});

  final String workspaceId;

  /// The table or call number when the order has one, else its customer,
  /// else null (the screen names the order by its id).
  final String? label;
  final tickets = <KitchenTicket>[];
}

String? orderLabel(KitchenTicket ticket) => headerLabel((key) => ticket.header[key]?.value);

/// The table, call number or customer a ticket header names, or null.
/// [field] reads one header field.
String? headerLabel(Object? Function(String key) field) {
  for (final key in ['table', 'order_number', 'customer_name']) {
    final value = field(key);
    if (value is String && value.isNotEmpty) return value;
    if (value is num) return '$value';
  }
  return null;
}

/// Open tickets by order, the order waiting longest first.
List<OrderGroup> groupByOrder(Iterable<KitchenTicket> tickets) {
  final groups = <String, OrderGroup>{};
  for (final ticket in tickets) {
    groups.putIfAbsent(ticket.workspaceId, () => OrderGroup(workspaceId: ticket.workspaceId, label: orderLabel(ticket)))
        .tickets
        .add(ticket);
  }
  return groups.values.toList()..sort((a, b) => a.tickets.first.sentAt.compareTo(b.tickets.first.sentAt));
}

/// The ticket header field as text, or null.
String? headerText(KitchenTicket ticket, String key) {
  final value = ticket.header[key]?.value;
  return value is String && value.isNotEmpty ? value : null;
}
