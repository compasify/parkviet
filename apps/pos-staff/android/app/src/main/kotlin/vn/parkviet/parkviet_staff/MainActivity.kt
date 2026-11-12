package vn.parkviet.parkviet_staff

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

// A fragment activity: the fingerprint prompt (local_auth) needs one.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        BluetoothSppChannel(applicationContext).register(flutterEngine.dartExecutor.binaryMessenger)
        KioskLockChannel(this).register(flutterEngine.dartExecutor.binaryMessenger)
    }
}
