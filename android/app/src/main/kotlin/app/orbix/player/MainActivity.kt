package app.orbix.player

import android.app.PictureInPictureParams
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import android.provider.Settings
import android.util.Rational
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Player window helpers for Dart (`lib/features/player/player_window.dart`):
 * picture-in-picture (manual and auto-enter on leave), per-window brightness
 * for the player's brightness gesture, and opening the network settings.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    /** Set while a video is playing: PiP on Home / recents (API 26–30 path). */
    private var autoPip = false
    private var aspect = Rational(16, 9)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.orbix.player/window").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "pipSupported" -> result.success(pipSupported())
                    "enterPip" -> {
                        aspectFrom(call.argument<Int>("w"), call.argument<Int>("h"))
                        result.success(enterPip())
                    }
                    "setAutoPip" -> {
                        autoPip = call.argument<Boolean>("enabled") == true
                        aspectFrom(call.argument<Int>("w"), call.argument<Int>("h"))
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && pipSupported()) {
                            setPictureInPictureParams(params().setAutoEnterEnabled(autoPip).setSeamlessResizeEnabled(true).build())
                        }
                        result.success(null)
                    }
                    "getBrightness" -> result.success(brightness())
                    "openNetworkSettings" -> {
                        startActivity(Intent(Settings.ACTION_WIRELESS_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                        result.success(null)
                    }
                    "setBrightness" -> {
                        val v = call.argument<Double>("value") ?: -1.0
                        window.attributes = window.attributes.apply {
                            screenBrightness = if (v < 0) WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE else v.toFloat().coerceIn(0.01f, 1f)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun pipSupported() = packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)

    private fun aspectFrom(w: Int?, h: Int?) {
        if (w == null || h == null || w <= 0 || h <= 0) return
        // Android rejects ratios outside 1:2.39 … 2.39:1.
        val r = w.toDouble() / h
        aspect = if (r in 0.42..2.39) Rational(w, h) else Rational(16, 9)
    }

    private fun params() = PictureInPictureParams.Builder().setAspectRatio(aspect)

    private fun enterPip(): Boolean {
        if (!pipSupported()) return false
        return try {
            enterPictureInPictureMode(params().build())
        } catch (e: IllegalStateException) {
            false
        }
    }

    /** Window override if set, otherwise the system brightness (0…1). */
    private fun brightness(): Double {
        val own = window.attributes.screenBrightness
        if (own >= 0) return own.toDouble()
        return try {
            Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS) / 255.0
        } catch (e: Settings.SettingNotFoundException) {
            0.5
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (autoPip && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) enterPip()
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        channel?.invokeMethod("pipChanged", isInPictureInPictureMode)
    }
}
