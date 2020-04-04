package dev.slebe.draw_a_lot;

import androidx.annotation.NonNull;
import android.media.MediaScannerConnection;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.util.Log;
import android.net.Uri;
import android.os.Environment;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "slebe.dev/draw-a-lot";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler((call, result) -> {
          if (call.method.equals("rescanGallery")) {
            final String path = call.argument("path");
            rescanGallery(path);
            result.success(null);
          } else if (call.method.equals("getExternalStoragePublicDirectory")) {
              final String type = call.argument("type");
              result.success(Environment.getExternalStoragePublicDirectory(type).toString());
          } else {
            result.notImplemented();
          }
        });
  }

  private void rescanGallery(String path) {
    if (VERSION.SDK_INT >= VERSION_CODES.DONUT) {
      // Tell the media scanner about the new file so that it is
      // immediately available to the user.
      MediaScannerConnection.scanFile(this, new String[] { path }, null,
          new MediaScannerConnection.OnScanCompletedListener() {
            public void onScanCompleted(String path, Uri uri) {
              Log.i("ExternalStorage", "Scanned " + path + ":");
              Log.i("ExternalStorage", "-> uri=" + uri);
            }
          });
    }
  }
}
