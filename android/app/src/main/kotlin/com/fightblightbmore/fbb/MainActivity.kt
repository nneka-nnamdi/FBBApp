package com.fightblightbmore.fbb

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Base64
import android.util.Log
import java.math.BigInteger
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
    private val CHANNEL = "google_map_location_picker"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flavor").setMethodCallHandler {
                call, result -> result.success(BuildConfig.FLAVOR)
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            // Note: this method is invoked on the main thread.
            if (call.method == "getSigningCertSha1") {
                try {
                    val info: PackageInfo = activity.getPackageManager().getPackageInfo(call.arguments<String>(), PackageManager.GET_SIGNATURES)
                    for (signature in info.signatures) {
                        val md: MessageDigest = MessageDigest.getInstance("SHA1")
                        md.update(signature.toByteArray())

                        val bytes: ByteArray = md.digest()
                        val bigInteger: BigInteger = BigInteger(1, bytes)
                        val hex: String = String.format("%0" + (bytes.size shl 1) + "x", bigInteger)

                        result.success(hex)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.toString(), null)
                }
            }
        }

    }
}
