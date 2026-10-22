package com.nahro.arqamy

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.nahro.arqamy/whatsapp"
        ).setMethodCallHandler { call, result ->
            if (call.method != "sharePdfToWhatsApp") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val filePath = call.argument<String>("filePath")
            if (filePath == null) {
                result.error("INVALID_FILE_PATH", "Invoice file path is missing.", null)
                return@setMethodCallHandler
            }
            val file = File(filePath)
            if (!file.isFile) {
                result.error("INVOICE_NOT_FOUND", "Invoice file was not found.", null)
                return@setMethodCallHandler
            }
            val uri: Uri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.provider",
                file
            )
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "application/pdf"
                putExtra(Intent.EXTRA_STREAM, uri)
                clipData = ClipData.newUri(contentResolver, file.name, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                setPackage("com.whatsapp")
            }
            try {
                startActivity(intent)
                result.success(null)
            } catch (_: ActivityNotFoundException) {
                result.error(
                    "WHATSAPP_NOT_INSTALLED",
                    "WhatsApp is not installed.",
                    null
                )
            }
        }
    }
}