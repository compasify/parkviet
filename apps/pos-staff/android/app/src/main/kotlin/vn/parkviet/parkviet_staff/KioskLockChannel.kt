package vn.parkviet.parkviet_staff

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Keeps a self-ordering kiosk on the app: Android lock task mode. On a
 * device where the app is the device owner (the kiosk is provisioned that
 * way) the lock is silent and complete; otherwise Android pins the screen
 * and asks the person at the device once. The app leaves it only after a
 * manager's PIN (the Flutter side asks for it).
 */
class KioskLockChannel(private val activity: Activity) {
    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> result.run {
                    try {
                        activity.startLockTask()
                        success(true)
                    } catch (error: Exception) {
                        error("lock_failed", error.message, null)
                    }
                }
                "stop" -> result.run {
                    try {
                        activity.stopLockTask()
                        success(true)
                    } catch (error: Exception) {
                        error("unlock_failed", error.message, null)
                    }
                }
                "isLocked" -> result.success(isLocked())
                else -> result.notImplemented()
            }
        }
    }

    private fun isLocked(): Boolean {
        val manager = activity.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return manager.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
    }

    companion object {
        const val CHANNEL = "parkviet/kiosk"
    }
}
