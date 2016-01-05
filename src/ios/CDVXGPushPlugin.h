#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>

@interface CDVXGPushPlugin: CDVPlugin

- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification;
- (void) didFailToRegisterForRemoteNotificationsWithError:(NSNotification*)notification;
- (void) didReceiveRemoteNotification:(NSNotification*)notification;

- (void) registerPush:(CDVInvokedUrlCommand*)command;
- (void) unregisterPush:(CDVInvokedUrlCommand*)command;


@end
