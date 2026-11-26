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
            when (call.method) {
                "sharePdfToWhatsApp" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath == null) {
                        result.error("INVALID_FILE_PATH", "Invoice file path is missing.", null)
                        return@setMethodCallHandler
                    }
                    shareFiles(listOf(filePath), "application/pdf", "Invoice PDF", result)
                }
                "shareFilesToWhatsApp" -> {
                    val filePaths = call.argument<List<String>>("filePaths")
                    if (filePaths.isNullOrEmpty()) {
                        result.error("INVALID_FILE_PATH", "Invoice file paths are missing.", null)
                        return@setMethodCallHandler
                    }
                    shareFiles(filePaths, "*/*", "Invoice files", result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun shareFiles(
        filePaths: List<String>,
        mimeType: String,
        clipLabel: String,
        result: MethodChannel.Result,
    ) {
        val files = filePaths.map(::File)
        if (files.any { !it.isFile }) {
            result.error("INVOICE_NOT_FOUND", "An invoice file was not found.", null)
            return
        }

        val uris = ArrayList<Uri>(files.size)
        for (file in files) {
            uris.add(
                FileProvider.getUriForFile(
                    this,
                    "${applicationContext.packageName}.provider",
                    file,
                ),
            )
        }

        val clipData = ClipData.newUri(contentResolver, clipLabel, uris.first())
        for (uri in uris.drop(1)) {
            clipData.addItem(ClipData.Item(uri))
        }

        fun buildIntent(packageName: String): Intent = Intent(
            if (uris.size > 1) Intent.ACTION_SEND_MULTIPLE else Intent.ACTION_SEND,
        ).apply {
            type = mimeType
            if (uris.size > 1) {
                putExtra(Intent.EXTRA_STREAM, uris)
            } else {
                putExtra(Intent.EXTRA_STREAM, uris.first())
            }
            this.clipData = clipData
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            setPackage(packageName)
        }

        try {
            startActivity(buildIntent("com.whatsapp"))
            result.success(null)
        } catch (_: ActivityNotFoundException) {
            try {
                startActivity(buildIntent("com.whatsapp.w4b"))
                result.success(null)
            } catch (_: ActivityNotFoundException) {
                result.error(
                    "WHATSAPP_NOT_INSTALLED",
                    "WhatsApp is not installed.",
                    null,
                )
            }
        }
    }
}
