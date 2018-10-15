#import "CDVXGPushPlugin.h"
#import <Cordova/CDVPlugin.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

static NSDictionary *_luanchOptions=nil;
static CDVInvokedUrlCommand *currentCommand=nil;

@interface CDVXGPushPlugin ()<XGPushDelegate,XGPushTokenManagerDelegate>

@end

@implementation CDVXGPushPlugin


+(void)setLaunchOptions:(NSDictionary *)theLaunchOptions{
    if(theLaunchOptions){
        NSDictionary *opt=[theLaunchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        
        NSDictionary *alert=[[opt objectForKey:@"aps"] objectForKey:@"alert"];
        NSMutableDictionary *customContent=[NSMutableDictionary dictionaryWithCapacity:opt.count -2];
        for (NSString *key in opt) {
            if(![key isEqualToString:@"aps"]&![key isEqualToString:@"xg"])[customContent setObject:[opt valueForKey:key] forKey:key];
        }
        _luanchOptions = @{
                           @"content":[alert objectForKey:@"body"]?[alert objectForKey:@"body"]:@"",
                           @"title":[alert objectForKey:@"title"]?[alert objectForKey:@"title"]:@"",
                           @"subtitle":[alert objectForKey:@"subtitle"]?[alert objectForKey:@"subtitle"]:@"",
                           @"customContent":customContent
                        };
    }
}

/**
 * 插件初始化
 */
- (void) pluginInitialize {
 
    [XGPushTokenManager defaultTokenManager].delegate = self;
    uint32_t accessId = [[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"XGPushMeta"] valueForKey:@"AccessID"] intValue];
    NSString* accessKey = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"XGPushMeta"] valueForKey:@"AccessKey"];
    [self startApp:accessId key:accessKey];
    
}


- (void) didFailToRegisterForRemoteNotificationsWithError:(NSNotification*) notification {
    NSString *str = [NSString stringWithFormat: @"Error: %@",notification];
    NSLog(@"[XGPushPlugin]%@",str);
}


/**
 * 启动 xgpush
 */
- (void) startApp:(uint32_t)assessId key:(NSString*) accessKey {
    NSLog(@"[XGPushPlugin] starting with access id: %u, access key: %@", assessId, accessKey);
    
    [[XGPush defaultManager] startXGWithAppID:assessId appKey:accessKey delegate:self ];
    [[XGPush defaultManager] setXgApplicationBadgeNumber:0];
    
}


//------------------------------------------------------------------------

- (void) sendMessage:(NSString*) type data:(NSDictionary*)dict;{
    if(self.callbackId  != nil){
        NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:type,@"type",nil];
        [newDict addEntriesFromDictionary:dict];
        
        NSLog(@"[XGPushPlugin] send Message: %@", newDict);
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:newDict];
        
        [result setKeepCallback:[NSNumber numberWithBool:YES]];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) addListener:(CDVInvokedUrlCommand*)command {
    NSLog(@"[XGPushPlugin] add listener: %@", command.callbackId);
    self.callbackId = command.callbackId;
}

- (void) registerPush:(CDVInvokedUrlCommand*)command {
    NSString* account = [command.arguments objectAtIndex:0];
    currentCommand=command;
    NSLog(@"[XGPushPlugin] registerPush: account = %@, token = %@", account,[[XGPushTokenManager defaultTokenManager] deviceTokenString]);
    
    if ([account respondsToSelector:@selector(length)] && [account length] > 0) {
        NSLog(@"[XGPushPlugin] set account:%@", account);
        [[XGPushTokenManager defaultTokenManager] bindWithIdentifier:account type:XGPushTokenBindTypeAccount];
    }else{
        [self sendCallback:nil];
    }
}


- (void) unRegisterPush:(CDVInvokedUrlCommand*)command {
    NSString* account = [command.arguments objectAtIndex:0];
    NSLog(@"[XGPushPlugin] unRegisterPush");
    currentCommand=command;
    [[XGPushTokenManager defaultTokenManager] unbindWithIdentifer:account type:XGPushTokenBindTypeAccount];
}

- (void) getLaunchInfo:(CDVInvokedUrlCommand*)command {
    NSLog(@"[XGPushPlugin] getLaunchInfo");
    CDVPluginResult* result = nil;
    
    if(_luanchOptions){
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_luanchOptions];
    }else{
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void) setTag:(CDVInvokedUrlCommand*)command{
    currentCommand=command;
    NSString* name = [command.arguments objectAtIndex:0];
    NSLog(@"[XGPushPlugin] setTag: %@", name);
    
    [[XGPushTokenManager defaultTokenManager] bindWithIdentifier:name type:XGPushTokenBindTypeTag];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (void) deleteTag:(CDVInvokedUrlCommand*)command{
    currentCommand=command;
    NSString* name = [command.arguments objectAtIndex:0];
    NSLog(@"[XGPushPlugin] deleteTag: %@", name);
    
    [[XGPushTokenManager defaultTokenManager] unbindWithIdentifer:name type:XGPushTokenBindTypeTag];
}



- (void) addLocalNotification:(CDVInvokedUrlCommand*)command{
        //暂时不实现
//    NSDate *fireDate = [[NSDate new] dateByAddingTimeInterval:10];
//
//    NSMutableDictionary *dicUserInfo = [[NSMutableDictionary alloc] init];
//    [dicUserInfo setValue:@"myid" forKey:@"clockID"];
//    NSDictionary *userInfo = dicUserInfo;
}


- (void) enableDebug:(CDVInvokedUrlCommand*)command{
    BOOL enable = [[command.arguments objectAtIndex:0] boolValue];
    [[XGPush defaultManager] setEnableDebug:enable];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [result setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (void) getToken:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat: @"%@",[[XGPushTokenManager defaultTokenManager] deviceTokenString]]];
    [result setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (void) setAccessInfo:(CDVInvokedUrlCommand*)command{
    uint32_t accessId = [[command.arguments objectAtIndex:0] intValue];
    NSString* accessKey = [command.arguments objectAtIndex:1];
    
    [self startApp:accessId key:accessKey];
}

- (void) sendCallbackWithResult:(CDVPluginResult*) result{
    if(currentCommand==nil) return;
    if (result!=nil) {
        [self.commandDelegate sendPluginResult:result callbackId:currentCommand.callbackId];
    }
    currentCommand=nil;
}
- (void) sendCallback:(NSError*) error{
    if (error==nil) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self sendCallbackWithResult:result];
    } else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self sendCallbackWithResult:result];
    }
}

- (void)stopNotification:(CDVInvokedUrlCommand*)command{
    [[XGPush defaultManager] stopXGNotification];
}

#pragma mark - XGPushDelegate
- (void)xgPushDidFinishStart:(BOOL)isSuccess error:(NSError *)error {
    NSLog(@"%s, result %@, error %@", __FUNCTION__, isSuccess?@"OK":@"NO", error);
     [self sendCallback:error] ;
}

- (void)xgPushDidFinishStop:(BOOL)isSuccess error:(NSError *)error {
    [self sendCallback:error];
}

- (void)xgPushDidSetBadge:(BOOL)isSuccess error:(NSError *)error {
    NSLog(@"%s, result %@, error %@", __FUNCTION__, error?@"NO":@"OK", error);
}
- (void)xgPushDidRegisteredDeviceToken:(NSString *)deviceToken error:(NSError *)error{
    NSLog(@"%s, result %@, error %@", __FUNCTION__, error?@"NO":@"OK", error);
}
// iOS 10 新增 API
// iOS 10 会走新 API, iOS 10 以前会走到老 API
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// App 用户点击通知
// App 用户选择通知中的行为
// App 用户在通知中心清除消息
// 无论本地推送还是远程推送都会走这个回调
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"[XGDemo] click notification");
    
    [[XGPush defaultManager] reportXGNotificationResponse:response];
    UNNotificationContent *content= response.notification.request.content;
    NSDictionary *userInfo=content.userInfo;
    NSMutableDictionary *customContent=[NSMutableDictionary dictionaryWithCapacity:userInfo.count -2];
    for (NSString *key in userInfo) {
        if(![key isEqualToString:@"aps"]&![key isEqualToString:@"xg"])[customContent setObject:[userInfo valueForKey:key] forKey:key];
    }
    NSDictionary *data=@{
                         @"content":content.body?content.body:@"",
                         @"title":content.title?content.title:@"",
                         @"subtitle":content.subtitle?content.subtitle:@"",
                         @"customContent":customContent
                         };
    completionHandler();
    [self sendMessage:@"click" data:data];
}

// App 在前台弹通知需要调用这个接口
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    [[XGPush defaultManager] reportXGNotificationInfo:notification.request.content.userInfo];
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}
#endif

- (void)xgPushDidReceiveRemoteNotification:(id)notification withCompletionHandler:(void (^)(NSUInteger))completionHandler {
    if ([notification isKindOfClass:[NSDictionary class]]) {
        completionHandler(UIBackgroundFetchResultNewData);
    } else if ([notification isKindOfClass:[UNNotification class]]) {
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    }
}

/**
 收到通知消息的回调，通常此消息意味着有新数据可以读取（iOS 7.0+）
 
 @param application  UIApplication 实例
 @param userInfo 推送时指定的参数
 @param completionHandler 完成回调
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"[XGDemo] receive slient Notification");
    NSLog(@"[XGDemo] userinfo %@", userInfo);
    [[XGPush defaultManager] reportXGNotificationInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    [self sendMessage:@"message" data:userInfo];
}

#pragma mark - XGPushTokenManagerDelegate
- (void)xgPushDidBindWithIdentifier:(NSString *)identifier type:(XGPushTokenBindType)type error:(NSError *)error {
    
    NSLog(@"%s, id is %@, error %@", __FUNCTION__, identifier, error);
    if(error==nil){
        NSDictionary* data=@{
                             @"data":[[XGPushTokenManager defaultTokenManager] deviceTokenString]
                             };
        CDVPluginResult* result=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
        [self sendCallbackWithResult:result];
    }else{
       [self sendCallback:error];
    }
}

- (void)xgPushDidUnbindWithIdentifier:(NSString *)identifier type:(XGPushTokenBindType)type error:(NSError *)error{
   
    NSLog(@"%s, id is %@, error %@", __FUNCTION__, identifier, error);
    [self sendCallback:error];
}

- (void)xgPushDidBindWithIdentifiers:(NSArray<NSString *> *)identifiers type:(XGPushTokenBindType)type error:(NSError *)error {
    NSLog(@"%s, id is %@, error %@", __FUNCTION__, identifiers, error);
    [self sendCallback:error];
}

- (void)xgPushDidUnbindWithIdentifiers:(NSArray<NSString *> *)identifiers type:(XGPushTokenBindType)type error:(NSError *)error {
    NSLog(@"%s, id is %@, error %@", __FUNCTION__, identifiers, error);
    [self sendCallback:error];
}

- (void)xgPushDidUpdatedBindedIdentifiers:(NSArray<NSString *> *)identifiers bindType:(XGPushTokenBindType)type error:(NSError *)error {
    NSLog(@"%s, id is %@, error %@", __FUNCTION__, identifiers, error);
    [self sendCallback:error];
}

- (void)xgPushDidClearAllIdentifiers:(XGPushTokenBindType)type error:(NSError *)error {
    NSLog(@"%s, type is %lu, error %@", __FUNCTION__, (unsigned long)type, error);
    [self sendCallback:error];
}

@end
