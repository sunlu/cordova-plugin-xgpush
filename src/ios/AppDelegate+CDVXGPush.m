#import "AppDelegate+CDVXGPush.h"

@implementation AppDelegate (CDVXGPush)

- (void) application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
  NSLog(@"[AppDelegate] receive remote notification");
  [[NSNotificationCenter defaultCenter] postNotificationName: @"receivenotification" object:userInfo];
}

@end
