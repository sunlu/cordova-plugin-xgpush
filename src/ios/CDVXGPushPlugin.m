#import "CDVXGPushPlugin.h"
#import "XGPush.h"
#import "XGSetting.h"


static NSDictionary *_luanchOptions=nil;

@implementation CDVXGPushPlugin


+(void)setLaunchOptions:(NSDictionary *)theLaunchOptions{
    _luanchOptions = theLaunchOptions;
}

/*
 notification
 */

- (void) registerNotificationForIOS7{
    NSLog(@"[CDVXGPushPlugin] register under ios 8");
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void) registerNotificationForIOS8
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    NSLog(@"[CDVXGPushPlugin] register ios 8");
    
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction* acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory* inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    // using arc
    // [acceptAction release];
    
    NSSet* categories = [NSSet setWithObjects:inviteCategory, nil];
    
    // using arc
    // [inviteCategory release];
    
    UIUserNotificationSettings* mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void) registerNotification
{
    NSLog(@"[CDVXGPushPlugin] register notification");
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    // iOS8注册push方法
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysVer < 8) {
        
        [self registerNotificationForIOS7];
    } else {
        [self registerNotificationForIOS8];
    }
#else
    // iOS8之前注册push方法
    // 注册Push服务，注册后才能收到推送
    [self registerNotificationForIOS7];
#endif
}



/**
 * 插件初始化
 */
- (void) pluginInitialize {
    // 注册获取 token 回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterForRemoteNotificationsWithDeviceToken:) name:CDVRemoteNotification object:nil];
    
    // 注册错误回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToRegisterForRemoteNotificationsWithError:) name:CDVRemoteNotificationError object:nil];
    
    // 注册接收回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:kXGPushPluginReceiveNotification object:nil];
    
    uint32_t accessId = [[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"XGPushMeta"] valueForKey:@"AccessID"] intValue];
    NSString* accessKey = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"XGPushMeta"] valueForKey:@"AccessKey"];
    
    [self startApp:accessId key:accessKey];
}


- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification {
    NSLog(@"[XGPushPlugin] receive device token: %@", notification.object);
    self.deviceToken = notification.object;
}

- (void) didFailToRegisterForRemoteNotificationsWithError:(NSNotification*) notification {
    NSString *str = [NSString stringWithFormat: @"Error: %@",notification];
    NSLog(@"[XGPushPlugin]%@",str);
}

- (void) didReceiveRemoteNotification:(NSNotification*)notification {
    NSLog(@"[XGPushPlugin] receive notification: %@", notification);
    
    //推送反馈(app运行时)
    [XGPush handleReceiveNotification:notification.object];
    
    [self sendMessage:@"message" data:notification.object];
}

/**
 * 启动 xgpush
 */
- (void) startApp:(uint32_t)assessId key:(NSString*) accessKey {
    
    NSLog(@"[XGPushPlugin] starting with access id: %u, access key: %@", assessId, accessKey);
    
    [XGPush startApp:assessId appKey:accessKey];
    
    [XGPush initForReregister:^{
        if (![XGPush isUnRegisterStatus]) {
            [self registerNotification];
        }
    }];
    
    //角标清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
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
    
    NSLog(@"[XGPushPlugin] registerPush: account = %@, token = %@", account, self.deviceToken);
    
    if ([account respondsToSelector:@selector(length)] && [account length] > 0) {
        NSLog(@"[XGPushPlugin] set account:%@", account);
        [XGPush setAccount:account];
    }
    
    // FIXME: 放到 background thread 里运行时无法执行回调
    NSString * result = [XGPush registerDevice:self.deviceToken successCallback:^{
        // 成功
        NSLog(@"[XGPushPlugin] registerPush success");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    } errorCallback:^{
        // 失败
        NSLog(@"[XGPushPlugin] registerPush error");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
    
    NSLog(@"[XGPushPlugin] registerDevice result = %@",result);
}


- (void) unRegisterPush:(CDVInvokedUrlCommand*)command {
    NSLog(@"[XGPushPlugin] unRegisterPush");
    
    // FIXME: 放到 background thread 里运行时无法执行回调
    [XGPush unRegisterDevice:^{
        // 成功
        NSLog(@"[XGPushPlugin] deregisterpush success");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    } errorCallback:^{
        // 失败
        NSLog(@"[XGPushPlugin] deregisterpush error");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    }];
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
    NSString* name = [command.arguments objectAtIndex:0];
    NSLog(@"[XGPushPlugin] setTag: %@", name);
    
    [XGPush setTag:name successCallback:^{
        // 成功
        NSLog(@"[XGPushPlugin] setTag success");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    } errorCallback:^{
        // 失败
        NSLog(@"[XGPushPlugin] setTag error");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}


- (void) deleteTag:(CDVInvokedUrlCommand*)command{
    NSString* name = [command.arguments objectAtIndex:0];
    NSLog(@"[XGPushPlugin] deleteTag: %@", name);
    
    [XGPush delTag:name successCallback:^{
        // 成功
        NSLog(@"[XGPushPlugin] deleteTag success");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    } errorCallback:^{
        // 失败
        NSLog(@"[XGPushPlugin] deleteTag error");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}



- (void) addLocalNotification:(CDVInvokedUrlCommand*)command{
    
    NSDate *fireDate = [[NSDate new] dateByAddingTimeInterval:10];
    
    NSMutableDictionary *dicUserInfo = [[NSMutableDictionary alloc] init];
    [dicUserInfo setValue:@"myid" forKey:@"clockID"];
    NSDictionary *userInfo = dicUserInfo;
    
    [XGPush localNotification:fireDate alertBody:@"测试本地推送" badge:2 alertAction:@"确定" userInfo:userInfo];
    
    //[XGPush localNotification:<#(NSDate *)#> alertBody:<#(NSString *)#> badge:<#(int)#> alertAction:<#(NSString *)#> userInfo:<#(NSDictionary *)#>];
}


- (void) enableDebug:(CDVInvokedUrlCommand*)command{
    BOOL enable = [[command.arguments objectAtIndex:0] boolValue];
    
    XGSetting *setting = [XGSetting getInstance];
    
    [setting enableDebug:enable];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [result setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (void) getToken:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat: @"%@",self.deviceToken]];
    [result setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}


- (void) setAccessInfo:(CDVInvokedUrlCommand*)command{
    uint32_t accessId = [[command.arguments objectAtIndex:0] intValue];
    NSString* accessKey = [command.arguments objectAtIndex:1];
    
    [self startApp:accessId key:accessKey];
}




@end
