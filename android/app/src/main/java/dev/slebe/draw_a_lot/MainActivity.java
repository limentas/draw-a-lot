package dev.slebe.draw_a_lot;

import java.io.File;
import java.io.OutputStream;
import java.io.IOException;
import androidx.annotation.NonNull;
import android.media.MediaScannerConnection;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.util.Log;
import android.net.Uri;
import android.os.Environment;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.Manifest;
import android.content.pm.PackageManager;
import android.provider.MediaStore;
import android.content.ContentResolver;
import android.content.ContentValues;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "slebe.dev/draw-a-lot";

  private static final int GET_PERMISSION_RESULT_ALLOW = 0;
  private static final int GET_PERMISSION_RESULT_PENDING = 1;
  private static final int GET_PERMISSION_RESULT_DENY = 2;

  private static final int WRITE_PERMISSION_REQUEST_CODE = 1;

  private MethodChannel _channel;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    _channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    _channel.setMethodCallHandler((call, result) -> {
      if (call.method.equals("rescanGallery")) {
        final String path = call.argument("path");
        rescanGallery(path);
        result.success(null);
      } else if (call.method.equals("getExternalStoragePublicDirectory")) {
        final String type = call.argument("type");
        result.success(Environment.getExternalStoragePublicDirectory(type).toString());
      } else if (call.method.equals("checkAndRequestWritePermissions")) {
        result.success(checkAndRequestWritePermissions() == GET_PERMISSION_RESULT_ALLOW);
      } else if (call.method.equals("saveImageToGallery")) {
        final byte[] imagePngData = call.argument("imagePngData");
        result.success(saveIamgeToGallery(imagePngData));
      } else {
        result.notImplemented();
      }
    });
  }

  private boolean saveIamgeToGallery(byte[] imagePngData) {
    final String relativePath = Environment.DIRECTORY_PICTURES + File.separator + "DrawALot"; // save directory
    String fileName = "file.png"; // file name to save file with
    String mimeType = "image/png"; // Mime Types define here

    final ContentValues contentValues = new ContentValues();
    contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, fileName);
    contentValues.put(MediaStore.MediaColumns.MIME_TYPE, mimeType);
    contentValues.put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath);

    final ContentResolver resolver = this.getContentResolver();

    OutputStream stream = null;
    Uri uri = null;

    try {
      final Uri contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
      uri = resolver.insert(contentUri, contentValues);

      Log.d("MainActivity", "uri = " + uri);

      if (uri == null) {
        Log.d("error", "Failed to create new MediaStore record.");
        return false;
      }

      stream = resolver.openOutputStream(uri);

      if (stream == null) {
        Log.d("error", "Failed to get output stream.");
      }

      stream.write(imagePngData);

      return true;
    } catch (IOException e) {
      Log.d("MainActivity", "e = " + e);
      if (uri != null) {
        resolver.delete(uri, null, null);
      }
      return false;
    } finally {
      try {
        if (stream != null) {
          stream.close();
        }
      } catch (IOException e) {
        Log.d("MainActivity", "close e = " + e);
      }
    }
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

  private int checkAndRequestWritePermissions() {
    {

    }

    if (VERSION.SDK_INT >= VERSION_CODES.Q) // on Android Q we will use mediastore
      return GET_PERMISSION_RESULT_ALLOW;
    if (ContextCompat.checkSelfPermission(this,
        Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
      return GET_PERMISSION_RESULT_ALLOW;
    }
    // Permission is not granted
    // No explanation needed; request the permission
    ActivityCompat.requestPermissions(this, new String[] { Manifest.permission.WRITE_EXTERNAL_STORAGE },
        WRITE_PERMISSION_REQUEST_CODE);

    return GET_PERMISSION_RESULT_PENDING;
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    Log.d("MainActivity", "onRequestPermissionsResult");
    switch (requestCode) {
      case WRITE_PERMISSION_REQUEST_CODE: {
        // If request is cancelled, the result arrays are empty.
        if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
          _channel.invokeMethod("setPermissionRequestResult", true);
        } else {
          _channel.invokeMethod("setPermissionRequestResult", false);
        }
        return;
      }
    }

    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
  }

}
