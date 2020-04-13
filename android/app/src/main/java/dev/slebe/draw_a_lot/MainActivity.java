package dev.slebe.draw_a_lot;

import java.io.File;
import java.io.OutputStream;
import java.io.IOException;
import java.lang.String;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.io.FileOutputStream;

import android.media.MediaScannerConnection;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Environment;
import android.os.Bundle;
import android.util.Log;
import android.net.Uri;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.annotation.NonNull;
import android.Manifest;
import android.content.pm.PackageManager;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.provider.MediaStore;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private static final String LOG_TAG = "DrawALot";
  private static final String CHANNEL = "slebe.dev/draw-a-lot";

  private static final int GET_PERMISSION_RESULT_ALLOW = 0;
  private static final int GET_PERMISSION_RESULT_PENDING = 1;
  private static final int GET_PERMISSION_RESULT_DENY = 2;

  private static final int WRITE_PERMISSION_REQUEST_CODE = 1;

  private MethodChannel _channel;

  private byte[] imageToSaveData = null;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    _channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    _channel.setMethodCallHandler((call, result) -> {
      if (call.method.equals("saveImageToGallery")) {
        final byte[] imagePngData = call.argument("imagePngData");
        result.success(saveImageToGallery(imagePngData));
      } else {
        result.notImplemented();
      }
    });
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    Log.d(LOG_TAG, "onRequestPermissionsResult code = " + requestCode);
    switch (requestCode) {
      case WRITE_PERMISSION_REQUEST_CODE: {
        // If request is cancelled, the result arrays are empty.
        if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
          if (imageToSaveData != null) {
            saveImageToGalleryApi1(imageToSaveData);
            imageToSaveData = null;
          }
        } else {
          imageToSaveData = null;
        }
        return;
      }
    }

    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
  }

  private boolean saveImageToGallery(byte[] imagePngData) {
    if (VERSION.SDK_INT < 23)
      return saveImageToGalleryApi1(imagePngData);
    if (VERSION.SDK_INT < 29)
      return saveImageToGalleryApi23(imagePngData);
    return saveImageToGalleryApi29(imagePngData);
  }

  private boolean saveImageToGalleryApi1(byte[] imagePngData) {
    Log.d(LOG_TAG, "saveImageToGalleryApi1");
    File path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
    path = new File(path, "DrawALot");

    try {
      // Make sure the Pictures directory exists.
      path.mkdirs();
    } catch (SecurityException e) {
      Log.w(LOG_TAG, "Error creating dir " + path, e);
      return false;
    }
    int num = 0;
    File file = null;
    do {
      file = new File(path, createBaseFileName(num++));
    }
    while(file.exists());

    OutputStream stream = null;
    try {
      stream = new FileOutputStream(file);
      stream.write(imagePngData);
      stream.flush();

      rescanGallery(file.getPath());
      return true;
    } catch (IOException e) {
      // Unable to create file, likely because external storage is
      // not currently mounted.
      Log.w(LOG_TAG, "Error writing " + file, e);
    } finally {
      try {
        if (stream != null) {
          stream.close();
        }
      } catch (IOException e) {
        Log.w(LOG_TAG, "Failure during closing stream e = " + e);
      }
    }
    return false;
  }

  private boolean saveImageToGalleryApi23(byte[] imagePngData) {
    Log.d(LOG_TAG, "saveImageToGalleryApi23");
    int checkResult = checkAndRequestWritePermissions();
    if (checkResult == GET_PERMISSION_RESULT_DENY)
      return false;
    else if (checkResult == GET_PERMISSION_RESULT_ALLOW)
      return saveImageToGalleryApi1(imagePngData);
    else
      imageToSaveData = imagePngData;
    return true;
  }

  private boolean saveImageToGalleryApi29(byte[] imagePngData) {
    Log.d(LOG_TAG, "saveImageToGalleryApi29");
    final String relativePath = Environment.DIRECTORY_PICTURES + File.separator + "DrawALot"; // save directory
    String fileName = createBaseFileName(0); // file name to save file with
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
      Log.d(LOG_TAG, "uri = " + uri);

      if (uri == null) {
        Log.w(LOG_TAG, "Failed to create new MediaStore record.");
        return false;
      }

      stream = resolver.openOutputStream(uri);
      if (stream == null) {
        Log.w(LOG_TAG, "Failed to get output stream.");
      }

      stream.write(imagePngData);
      return true;
    } catch (IOException e) {
      Log.w(LOG_TAG, "Failure during saving image e = " + e);
      if (uri != null) {
        resolver.delete(uri, null, null);
      }
    } finally {
      try {
        if (stream != null) {
          stream.close();
        }
      } catch (IOException e) {
        Log.w(LOG_TAG, "Failure during closing stream e = " + e);
      }
    }
    return false;
  }

  private String createBaseFileName(int numSuffix) {
    SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd-HHmm");
    if (numSuffix <= 0)
      return String.format("%s.png", format.format(new Date()));
    return String.format("%s(%d).png", format.format(new Date()), numSuffix);
  }

  private void rescanGallery(String pathToScan) {
    if (VERSION.SDK_INT >= 8 && VERSION.SDK_INT < 29) {
      // Tell the media scanner about the new file so that it is
      // immediately available to the user.
      MediaScannerConnection.scanFile(this, new String[] { pathToScan }, new String[] { "image/png" },
          new MediaScannerConnection.OnScanCompletedListener() {
            public void onScanCompleted(String path, Uri uri) {
              Log.i(LOG_TAG, "Scanned " + path + ":");
              Log.i(LOG_TAG, "-> uri=" + uri);
            }
          });
    }
  }

  private int checkAndRequestWritePermissions() {
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
}
