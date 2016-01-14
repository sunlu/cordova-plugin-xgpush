#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>

#import "XGPush.h"
#import "XGSetting.h"

#define kXGPushPluginReceiveNotification @"XGPushPluginReceiveNofication"

typedef void (^CallbackBlock) (void);

@interface CDVXGPushPlugin: CDVPlugin{
}

+(void)setLaunchOptions:(NSDictionary *)theLaunchOptions;

/*
 notification
 */
- (void) registerNotificationForIOS7;
- (void) registerNotificationForIOS8;
- (void) registerNotification;

/*
 plugin
 */
- (void) startApp:(uint32_t)assessId key:(NSString*) accessKey;

- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
- (void) didFailToRegisterForRemoteNotificationsWithError:(NSError*)err;
- (void) didReceiveRemoteNotification:(NSDictionary*)userInfo;

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

@property NSData* deviceToken;
@property (nonatomic, copy) NSString* callbackId;

@end
