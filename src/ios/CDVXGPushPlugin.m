#import "CDVXGPushPlugin.h"
#import "XGPush.h"


static NSDictionary *_luanchOptions=nil;

@implementation CDVXGPushPlugin


+(void)setLaunchOptions:(NSDictionary *)theLaunchOptions{
    _luanchOptions=theLaunchOptions;
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
 * 启动 xgpush
 */
- (void) startApp {
    uint32_t accessID = [[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"XGPushMeta"] valueForKey:@"AccessID"] intValue];
    NSString* accessKey = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"XGPushMeta"] valueForKey:@"AccessKey"];
    NSLog(@"[XGPush] starting with access id: %u, access key: %@", accessID, accessKey);
    [XGPush startApp:accessID appKey:accessKey];
    
    [XGPush initForReregister:^{
        if (![XGPush isUnRegisterStatus]) {
            [self registerNotification];
        }
    }];
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
    
    [self startApp];
}


- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification {
    NSLog(@"[XGPushPlugin] receive device token: %@", notification.object);
    self.deviceToken = notification.object;
}

- (void) didFailToRegisterForRemoteNotificationsWithError:(NSNotification*)notification {
    NSLog(@"[XGPushPlugin] register fail");
}

- (void) didReceiveRemoteNotification:(NSNotification*)notification {
    NSLog(@"[XGPushPlugin] receive notification: %@", notification);
    [self sendMessage:@"message" data:notification.object];
}



//------------------------------------------------------------------------

- (void) sendMessage:(NSString*) type data:(NSDictionary*)dict;{
    if(self.callbackId  != nil){
        NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:type,@"type",nil];
        [newDict addEntriesFromDictionary:dict];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:newDict];
        [result setKeepCallback:[NSNumber numberWithBool:YES]];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) addListener:(CDVInvokedUrlCommand*)command {
    NSLog(@"[XGPushPlugin] add listener: %@", command.callbackId);
    self.callbackId = command.callbackId;
    
    if(_luanchOptions){
        [self sendMessage:@"click" data:_luanchOptions];
    }
}

- (void) registerPush:(CDVInvokedUrlCommand*)command {
    NSString* alias = [command.arguments objectAtIndex:0];
    NSLog(@"[XGPushPlugin] registerpush: %@", alias);
    
    if ([alias respondsToSelector:@selector(length)] && [alias length] > 0) {
        NSLog(@"[XGPush] setting alias:%@", alias);
        [XGPush setAccount:alias];
    }
    
    // FIXME: 放到 background thread 里运行时无法执行回调
    [XGPush registerDevice:alias successCallback:^{
        // 成功
        NSLog(@"[XGPushPlugin] registerpush success");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    } errorCallback:^{
        // 失败
        NSLog(@"[XGPushPlugin] registerpush error");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}


- (void) unregisterPush:(CDVInvokedUrlCommand*)command {
    NSLog(@"[XGPushPlugin] registerpush");
    
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


//setTag
//delTag

//addLocalNotification


@end
