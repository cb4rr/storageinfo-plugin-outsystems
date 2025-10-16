#import <Cordova/CDV.h>

@interface StorageInfoPlugin : CDVPlugin

- (void)getStorageInfo:(CDVInvokedUrlCommand*)command;
- (void)getAppSize:(CDVInvokedUrlCommand*)command;
- (void)getAllInfo:(CDVInvokedUrlCommand*)command;

@end