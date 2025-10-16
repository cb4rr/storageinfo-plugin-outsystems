#import "StorageInfoPlugin.h"
#import <sys/stat.h>

@implementation StorageInfoPlugin

- (void)getStorageInfo:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            NSError *error = nil;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
            
            if (dictionary) {
                NSNumber *totalSpace = [dictionary objectForKey:NSFileSystemSize];
                NSNumber *freeSpace = [dictionary objectForKey:NSFileSystemFreeSize];
                
                unsigned long long totalBytes = [totalSpace unsignedLongLongValue];
                unsigned long long freeBytes = [freeSpace unsignedLongLongValue];
                unsigned long long usedBytes = totalBytes - freeBytes;
                
                NSDictionary *result = @{
                    @"totalSpace": @(totalBytes),
                    @"freeSpace": @(freeBytes),
                    @"usedSpace": @(usedBytes),
                    @"totalSpaceMB": @([self bytesToMB:totalBytes]),
                    @"freeSpaceMB": @([self bytesToMB:freeBytes]),
                    @"usedSpaceMB": @([self bytesToMB:usedBytes]),
                    @"totalSpaceGB": @([self bytesToGB:totalBytes]),
                    @"freeSpaceGB": @([self bytesToGB:freeBytes]),
                    @"usedSpaceGB": @([self bytesToGB:usedBytes])
                };
                
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error getting storage info"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
        @catch (NSException *exception) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)getAppSize:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            // Obtener tamaño del bundle (app)
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            unsigned long long appSize = [self getDirectorySize:bundlePath];
            
            // Obtener tamaño de datos
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *libraryPath = [documentsDirectory stringByDeletingLastPathComponent];
            unsigned long long dataSize = [self getDirectorySize:libraryPath];
            
            // Obtener tamaño de cache
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
            unsigned long long cacheSize = [self getDirectorySize:cachePath];
            
            unsigned long long totalAppSize = appSize + dataSize + cacheSize;
            
            NSDictionary *result = @{
                @"appSize": @(appSize),
                @"dataSize": @(dataSize),
                @"cacheSize": @(cacheSize),
                @"totalAppSize": @(totalAppSize),
                @"appSizeMB": @([self bytesToMB:appSize]),
                @"dataSizeMB": @([self bytesToMB:dataSize]),
                @"cacheSizeMB": @([self bytesToMB:cacheSize]),
                @"totalAppSizeMB": @([self bytesToMB:totalAppSize])
            };
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        @catch (NSException *exception) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

- (void)getAllInfo:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        @try {
            // Storage info
            NSError *error = nil;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
            
            NSNumber *totalSpace = [dictionary objectForKey:NSFileSystemSize];
            NSNumber *freeSpace = [dictionary objectForKey:NSFileSystemFreeSize];
            
            unsigned long long totalBytes = [totalSpace unsignedLongLongValue];
            unsigned long long freeBytes = [freeSpace unsignedLongLongValue];
            unsigned long long usedBytes = totalBytes - freeBytes;
            
            NSDictionary *storage = @{
                @"totalSpace": @(totalBytes),
                @"freeSpace": @(freeBytes),
                @"usedSpace": @(usedBytes),
                @"totalSpaceGB": @([self bytesToGB:totalBytes]),
                @"freeSpaceGB": @([self bytesToGB:freeBytes]),
                @"usedSpaceGB": @([self bytesToGB:usedBytes])
            };
            
            // App size info
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            unsigned long long appSize = [self getDirectorySize:bundlePath];
            
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *libraryPath = [documentsDirectory stringByDeletingLastPathComponent];
            unsigned long long dataSize = [self getDirectorySize:libraryPath];
            
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
            unsigned long long cacheSize = [self getDirectorySize:cachePath];
            
            unsigned long long totalAppSize = appSize + dataSize + cacheSize;
            
            NSDictionary *app = @{
                @"appSize": @(appSize),
                @"dataSize": @(dataSize),
                @"cacheSize": @(cacheSize),
                @"totalAppSize": @(totalAppSize),
                @"appSizeMB": @([self bytesToMB:appSize]),
                @"dataSizeMB": @([self bytesToMB:dataSize]),
                @"cacheSizeMB": @([self bytesToMB:cacheSize]),
                @"totalAppSizeMB": @([self bytesToMB:totalAppSize])
            };
            
            NSDictionary *result = @{
                @"storage": storage,
                @"app": app
            };
            
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        @catch (NSException *exception) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}

#pragma mark - Helper Methods

- (unsigned long long)getDirectorySize:(NSString *)path {
    unsigned long long size = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSArray *filesArray = [fileManager subpathsOfDirectoryAtPath:path error:&error];
        
        if (!error) {
            for (NSString *fileName in filesArray) {
                NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil];
                size += [fileAttributes fileSize];
            }
        }
    }
    
    return size;
}

- (double)bytesToMB:(unsigned long long)bytes {
    return round((bytes / 1024.0 / 1024.0) * 100.0) / 100.0;
}

- (double)bytesToGB:(unsigned long long)bytes {
    return round((bytes / 1024.0 / 1024.0 / 1024.0) * 100.0) / 100.0;
}

@end