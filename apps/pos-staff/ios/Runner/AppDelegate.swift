import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      KioskLockChannel.register(messenger: controller.binaryMessenger)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

/// Keeps a self-ordering kiosk on the app. iOS lets an app enter Single App
/// Mode by itself only on a supervised device set up for it; elsewhere the
/// shop turns on Guided Access (triple-click), and the app reports whether it
/// is on so the kiosk can warn. Leaving needs a manager's PIN in the app.
enum KioskLockChannel {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "parkviet/kiosk", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "start":
        UIAccessibility.requestGuidedAccessSession(enabled: true) { started in
          result(started || UIAccessibility.isGuidedAccessEnabled)
        }
      case "stop":
        UIAccessibility.requestGuidedAccessSession(enabled: false) { stopped in
          result(stopped || !UIAccessibility.isGuidedAccessEnabled)
        }
      case "isLocked":
        result(UIAccessibility.isGuidedAccessEnabled)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
