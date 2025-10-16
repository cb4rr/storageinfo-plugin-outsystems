package com.cb4rr.cordova.plugin;
import android.os.Build;
import android.os.Environment;
import android.os.StatFs;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;

public class StorageInfoPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        
        if (action.equals("getStorageInfo")) {
            this.getStorageInfo(callbackContext);
            return true;
        }
        
        if (action.equals("getAppSize")) {
            this.getAppSize(callbackContext);
            return true;
        }
        
        if (action.equals("getAllInfo")) {
            this.getAllInfo(callbackContext);
            return true;
        }
        
        return false;
    }

    private void getStorageInfo(CallbackContext callbackContext) {
        try {
            JSONObject result = new JSONObject();
            
            // Obtener información de almacenamiento interno
            StatFs internalStat = new StatFs(Environment.getDataDirectory().getPath());
            long internalTotal = getTotalSpace(internalStat);
            long internalFree = getFreeSpace(internalStat);
            long internalUsed = internalTotal - internalFree;
            
            result.put("totalSpace", internalTotal);
            result.put("freeSpace", internalFree);
            result.put("usedSpace", internalUsed);
            result.put("totalSpaceMB", bytesToMB(internalTotal));
            result.put("freeSpaceMB", bytesToMB(internalFree));
            result.put("usedSpaceMB", bytesToMB(internalUsed));
            result.put("totalSpaceGB", bytesToGB(internalTotal));
            result.put("freeSpaceGB", bytesToGB(internalFree));
            result.put("usedSpaceGB", bytesToGB(internalUsed));
            
            callbackContext.success(result);
        } catch (Exception e) {
            callbackContext.error("Error getting storage info: " + e.getMessage());
        }
    }

    private void getAppSize(CallbackContext callbackContext) {
        try {
            JSONObject result = new JSONObject();
            
            ApplicationInfo appInfo = cordova.getActivity()
                .getPackageManager()
                .getApplicationInfo(cordova.getActivity().getPackageName(), 0);
            
            long appSize = new File(appInfo.sourceDir).length();
            long dataSize = getDirectorySize(new File(appInfo.dataDir));
            long cacheSize = getDirectorySize(cordova.getActivity().getCacheDir());
            long totalAppSize = appSize + dataSize + cacheSize;
            
            result.put("appSize", appSize);
            result.put("dataSize", dataSize);
            result.put("cacheSize", cacheSize);
            result.put("totalAppSize", totalAppSize);
            result.put("appSizeMB", bytesToMB(appSize));
            result.put("dataSizeMB", bytesToMB(dataSize));
            result.put("cacheSizeMB", bytesToMB(cacheSize));
            result.put("totalAppSizeMB", bytesToMB(totalAppSize));
            
            callbackContext.success(result);
        } catch (Exception e) {
            callbackContext.error("Error getting app size: " + e.getMessage());
        }
    }

    private void getAllInfo(CallbackContext callbackContext) {
        try {
            JSONObject result = new JSONObject();
            
            // Storage info
            StatFs internalStat = new StatFs(Environment.getDataDirectory().getPath());
            long internalTotal = getTotalSpace(internalStat);
            long internalFree = getFreeSpace(internalStat);
            long internalUsed = internalTotal - internalFree;
            
            JSONObject storage = new JSONObject();
            storage.put("totalSpace", internalTotal);
            storage.put("freeSpace", internalFree);
            storage.put("usedSpace", internalUsed);
            storage.put("totalSpaceGB", bytesToGB(internalTotal));
            storage.put("freeSpaceGB", bytesToGB(internalFree));
            storage.put("usedSpaceGB", bytesToGB(internalUsed));
            
            // App size info
            ApplicationInfo appInfo = cordova.getActivity()
                .getPackageManager()
                .getApplicationInfo(cordova.getActivity().getPackageName(), 0);
            
            long appSize = new File(appInfo.sourceDir).length();
            long dataSize = getDirectorySize(new File(appInfo.dataDir));
            long cacheSize = getDirectorySize(cordova.getActivity().getCacheDir());
            long totalAppSize = appSize + dataSize + cacheSize;
            
            JSONObject app = new JSONObject();
            app.put("appSize", appSize);
            app.put("dataSize", dataSize);
            app.put("cacheSize", cacheSize);
            app.put("totalAppSize", totalAppSize);
            app.put("appSizeMB", bytesToMB(appSize));
            app.put("dataSizeMB", bytesToMB(dataSize));
            app.put("cacheSizeMB", bytesToMB(cacheSize));
            app.put("totalAppSizeMB", bytesToMB(totalAppSize));
            
            result.put("storage", storage);
            result.put("app", app);
            
            callbackContext.success(result);
        } catch (Exception e) {
            callbackContext.error("Error getting all info: " + e.getMessage());
        }
    }

    // Métodos auxiliares
    private long getTotalSpace(StatFs stat) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            return stat.getTotalBytes();
        } else {
            return (long) stat.getBlockCount() * (long) stat.getBlockSize();
        }
    }

    private long getFreeSpace(StatFs stat) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            return stat.getAvailableBytes();
        } else {
            return (long) stat.getAvailableBlocks() * (long) stat.getBlockSize();
        }
    }

    private long getDirectorySize(File dir) {
        long size = 0;
        if (dir != null && dir.exists()) {
            File[] files = dir.listFiles();
            if (files != null) {
                for (File file : files) {
                    if (file.isDirectory()) {
                        size += getDirectorySize(file);
                    } else {
                        size += file.length();
                    }
                }
            }
        }
        return size;
    }

    private double bytesToMB(long bytes) {
        return Math.round((bytes / 1024.0 / 1024.0) * 100.0) / 100.0;
    }

    private double bytesToGB(long bytes) {
        return Math.round((bytes / 1024.0 / 1024.0 / 1024.0) * 100.0) / 100.0;
    }
}