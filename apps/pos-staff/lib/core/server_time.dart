/// The server's clock as seen from this device. Timers show `now()`; the
/// device never sends its own clock as data.
class ServerClock {
  const ServerClock(this.offset);

  /// Takes the server time from a response and the moments the request left
  /// and the answer came back; the midpoint stands for the server's instant.
  factory ServerClock.measure({
    required DateTime serverTime,
    required DateTime sentAt,
    required DateTime receivedAt,
  }) {
    final midpoint = sentAt.add(receivedAt.difference(sentAt) ~/ 2);
    return ServerClock(serverTime.difference(midpoint));
  }

  static const zero = ServerClock(Duration.zero);

  final Duration offset;

  DateTime now([DateTime? local]) => (local ?? DateTime.now()).add(offset);
}
