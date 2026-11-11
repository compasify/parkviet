package vn.parkviet.parkviet_staff

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        BluetoothSppChannel(applicationContext).register(flutterEngine.dartExecutor.binaryMessenger)
    }
}
