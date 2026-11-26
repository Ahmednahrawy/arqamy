package com.nahro.arqamy

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    companion object {
        private const val PICK_BACKUP_REQUEST_CODE = 4242
    }

    private var pendingBackupResult: MethodChannel.Result? = null

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.nahro.arqamy/backup"
        ).setMethodCallHandler { call, result ->
            if (call.method != "pickBackupFile") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (pendingBackupResult != null) {
                result.error("PICK_IN_PROGRESS", "A file picker is already open.", null)
                return@setMethodCallHandler
            }
            pendingBackupResult = result
            val chooser = Intent.createChooser(
                Intent(Intent.ACTION_GET_CONTENT).apply {
                    type = "*/*"
                    addCategory(Intent.CATEGORY_OPENABLE)
                },
                "Choose backup file",
            )
            try {
                startActivityForResult(chooser, PICK_BACKUP_REQUEST_CODE)
            } catch (_: ActivityNotFoundException) {
                pendingBackupResult = null
                result.error(
                    "NO_FILE_APP",
                    "No app can choose a file.",
                    null,
                )
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_BACKUP_REQUEST_CODE) return

        val result = pendingBackupResult ?: return
        pendingBackupResult = null
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }
        try {
            result.success(copyPickedFileToCache(data.data!!))
        } catch (error: Exception) {
            result.error("BACKUP_READ_FAILED", error.message, null)
        }
    }

    private fun copyPickedFileToCache(uri: Uri): String {
        var displayName = "restore-backup.json"
        val cursor = contentResolver.query(uri, null, null, null, null)
        try {
            if (cursor != null && cursor.moveToFirst()) {
                val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (nameIndex >= 0) {
                    cursor.getString(nameIndex)?.let {
                        if (it.isNotBlank()) displayName = it
                    }
                }
            }
        } finally {
            cursor?.close()
        }

        val safeName = displayName
            .substringAfterLast('/')
            .replace(Regex("[^A-Za-z0-9._-]"), "_")
            .take(100)
        val file = File(cacheDir, "picked-$safeName")
        val input = contentResolver.openInputStream(uri)
            ?: throw IllegalStateException("The selected file could not be opened.")
        input.use { source ->
            FileOutputStream(file).use { target -> source.copyTo(target) }
        }
        return file.path
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
