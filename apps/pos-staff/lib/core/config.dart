/// Timings and limits shared by the whole app.
abstract final class AppConfig {
  static const connectTimeout = Duration(seconds: 5);
  static const receiveTimeout = Duration(seconds: 15);

  /// A print station claims on this tick even when no event arrives.
  static const printPollInterval = Duration(seconds: 10);

  /// A signed-in person is signed out after this long without a touch. The
  /// server also ends the session after the branch's own idle limit.
  static const staffIdleTimeout = Duration(minutes: 5);

  /// How long the hidden manager area must be held.
  static const managerHoldDuration = Duration(seconds: 3);

  static const lanPrinterPort = 9100;
  static const printerSendTimeout = Duration(seconds: 15);
}
