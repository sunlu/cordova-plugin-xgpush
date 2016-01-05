#import "CDVXGPushPlugin.h"

@implementation CDVXGPushPlugin

/**
 * 插件初始化
 */
- (void) pluginInitialize {
  // 注册获取 token 回调
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterForRemoteNotificationsWithDeviceToken:) name:CDVRemoteNotification object:nil];

  // 注册错误回调
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToRegisterForRemoteNotificationsWithError:) name:CDVRemoteNotificationError object:nil];

  // 注册接收回调
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:@"receivenotification" object:nil];

}


- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification {
  NSLog(@"[XGPushPlugin] receive device token: %@", notification.object);
 
}

- (void) didFailToRegisterForRemoteNotificationsWithError:(NSNotification*)notification {
  NSLog(@"[XGPushPlugin] register fail");
}

- (void) didReceiveRemoteNotification:(NSNotification*)notification {
  NSLog(@"[XGPushPlugin] receive notification: %@", notification);
  NSLog(@"[XGPushPlugin] callback ids: %@", self.callbackIds);
 
}

- (void) registerPush:(CDVInvokedUrlCommand*)command {
  NSString* alias = [command.arguments objectAtIndex:0];
  NSLog(@"[XGPushPlugin] registerpush: %@", alias);

  
}
- (void) unregisterPush:(CDVInvokedUrlCommand*)command {
  NSLog(@"[XGPushPlugin] registerPush");
  
}


@end
