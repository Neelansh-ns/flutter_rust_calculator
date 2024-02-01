import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException


class VideoFrameExtractorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var flutterPluginBinding: FlutterPluginBinding

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "video_frame_extractor")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @RequiresApi(Build.VERSION_CODES.P)
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d("VideoFrameExtractor", "onMethodCall: ${call.method}")
        when (call.method) {
            "extractFrame" -> {
                val frameNumber = call.argument<Int>("frameNumber")
                val videoFilePath = call.argument<String>("videoPath")
                val framePath = extractFrame(frameNumber ?: 0, videoFilePath ?: "")
                result.success(framePath)
            }

            else -> result.notImplemented()
        }
    }

    @RequiresApi(Build.VERSION_CODES.P)
    private fun extractFrame(frameNumber: Int, videoPath: String): String? {
        return try {
            val retriever = MediaMetadataRetriever()
            retriever.setDataSource(videoPath)
            Log.e("VideoFrameExtractor", "Frame number: $frameNumber")
            val frame = retriever.getFrameAtIndex(frameNumber)
            val outputPath: String =
                File(flutterPluginBinding.applicationContext.cacheDir, "frame.png").absolutePath
            val out = FileOutputStream(outputPath, false)
            frame?.compress(Bitmap.CompressFormat.PNG, 100, out)
            out.close()
            retriever.release()
            outputPath
        } catch (e: IOException) {
            Log.e("VideoFrameExtractor", "Failed to extract frame: ${e.message}")
            null
        }
    }

}