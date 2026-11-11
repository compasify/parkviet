package vn.parkviet.parkviet_staff

import android.Manifest
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.UUID
import java.util.concurrent.Executors

/**
 * Writes bytes to a Bluetooth Classic printer over the Serial Port Profile,
 * which Flutter's BLE plugin cannot open. Answers `not_classic` for a BLE-only
 * device so the Dart side can fall back to BLE.
 */
class BluetoothSppChannel(private val context: Context) : MethodChannel.MethodCallHandler {
    private val worker = Executors.newSingleThreadExecutor()

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "write") {
            result.notImplemented()
            return
        }
        val address = call.argument<String>("address")
        val bytes = call.argument<ByteArray>("bytes")
        if (address == null || bytes == null) {
            result.error("bad_arguments", "address and bytes are required", null)
            return
        }
        worker.execute { write(address, bytes, result) }
    }

    private fun write(address: String, bytes: ByteArray, result: MethodChannel.Result) {
        val reply = { block: () -> Unit -> android.os.Handler(context.mainLooper).post(block) }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            context.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED
        ) {
            reply { result.error("permission", "Bluetooth permission not granted", null) }
            return
        }
        val adapter = (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager?)?.adapter
        if (adapter == null || !adapter.isEnabled) {
            reply { result.error("unavailable", "Bluetooth is off or missing", null) }
            return
        }
        val device = try {
            adapter.getRemoteDevice(address.uppercase())
        } catch (error: IllegalArgumentException) {
            reply { result.error("not_classic", "not a classic address", null) }
            return
        }
        if (device.type == BluetoothDevice.DEVICE_TYPE_LE) {
            reply { result.error("not_classic", "BLE-only device", null) }
            return
        }
        try {
            adapter.cancelDiscovery()
            device.createRfcommSocketToServiceRecord(SPP_UUID).use { socket ->
                socket.connect()
                socket.outputStream.write(bytes)
                socket.outputStream.flush()
                // Give the printer's buffer time to take the job before the
                // socket closes; some printers drop a job closed too early.
                Thread.sleep(CLOSE_DELAY_MS)
            }
            reply { result.success(null) }
        } catch (error: IOException) {
            reply { result.error("io", error.message ?: "write failed", null) }
        } catch (error: SecurityException) {
            reply { result.error("permission", error.message ?: "Bluetooth permission not granted", null) }
        }
    }

    companion object {
        const val CHANNEL = "vn.parkviet.staff/bluetooth_spp"
        private val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        private const val CLOSE_DELAY_MS = 300L
    }
}
