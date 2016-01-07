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

- (void) startApp;

- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification;
- (void) didFailToRegisterForRemoteNotificationsWithError:(NSNotification*)notification;
- (void) didReceiveRemoteNotification:(NSNotification*)notification;

- (void) registerPush:(CDVInvokedUrlCommand*)command;
- (void) unregisterPush:(CDVInvokedUrlCommand*)command;
- (void) addListener:(CDVInvokedUrlCommand*)command;
- (void) sendMessage:(NSString*) type data:(NSDictionary*)dict;

@property NSData* deviceToken;
@property (nonatomic, copy) NSString* callbackId;

@end
