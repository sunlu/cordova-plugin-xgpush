#import "AppDelegate+CDVXGPush.h"
#import "XGPush.h"
#import "CDVXGPushPlugin.h"

@implementation AppDelegate (CDVXGPush)

- (void) application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    NSLog(@"[AppDelegate] receive remote notification");
    [XGPush handleReceiveNotification:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName: kXGPushPluginReceiveNotification object:userInfo];
}

- (void) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    [XGPush handleLaunching: launchOptions];
    [CDVXGPushPlugin setLaunchOptions:launchOptions];
}

@end
