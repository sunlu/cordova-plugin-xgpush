#import "AppDelegate+CDVXGPush.h"
#import <objc/runtime.h>
#import "XGPush.h"
#import "CDVXGPushPlugin.h"

@implementation AppDelegate (CDVXGPush)



+(void)load{
    
    Method origin = class_getInstanceMethod([self class],@selector(init));
    Method swizzle =class_getInstanceMethod([self class], @selector(init_plus));
    method_exchangeImplementations(origin, swizzle);
}

-(instancetype)init_plus{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidLaunch:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    return [self init_plus];
}

-(void)applicationDidLaunch:(NSNotification *)notification{
    
    if (notification) {
        [CDVXGPushPlugin setLaunchOptions:notification.userInfo];
    }
}

- (void) application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    NSLog(@"[AppDelegate] receive remote notification");
//    [XGPush handleReceiveNotification:userInfo];
//    [[NSNotificationCenter defaultCenter] postNotificationName: kXGPushPluginReceiveNotification object:userInfo];
}



-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    NSLog(@"[AppDelegate] receive local notification");
    
    //notification是发送推送时传入的字典信息
//    [XGPush localNotificationAtFrontEnd:notification userInfoKey:@"clockID" userInfoValue:@"myid"];
    
    //删除推送列表中的这一条
//    [XGPush delLocalNotification:notification];
    
    //清空推送列表
    //[XGPush clearLocalNotifications];
}

@end
