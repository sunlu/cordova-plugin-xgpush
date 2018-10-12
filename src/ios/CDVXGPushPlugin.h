#import <Cordova/CDVPlugin.h>

#import "XGPush.h"


typedef void (^CallbackBlock) (void);

@interface CDVXGPushPlugin: CDVPlugin

+(void)setLaunchOptions:(NSDictionary *)theLaunchOptions;

/*
 notification
 */

/*
 plugin
 */
- (void) startApp:(uint32_t)assessId key:(NSString*) accessKey;

- (void) didFailToRegisterForRemoteNotificationsWithError:(NSError*)err;

- (void) sendMessage:(NSString*) type data:(NSDictionary*)dict;

- (void) addListener:(CDVInvokedUrlCommand*)command;
- (void) registerPush:(CDVInvokedUrlCommand*)command;
- (void) unRegisterPush:(CDVInvokedUrlCommand*)command;
- (void) getLaunchInfo:(CDVInvokedUrlCommand*)command;

- (void) setTag:(CDVInvokedUrlCommand*)command;
- (void) deleteTag:(CDVInvokedUrlCommand*)command;

- (void) addLocalNotification:(CDVInvokedUrlCommand*)command;

- (void) enableDebug:(CDVInvokedUrlCommand*)command;
- (void) getToken:(CDVInvokedUrlCommand*)command;
- (void) setAccessInfo:(CDVInvokedUrlCommand*)command;
- (void) stopNotification:(CDVInvokedUrlCommand*)command;

@property (nonatomic, copy) NSString* callbackId;

@end
