# 腾讯信鸽推送 for Cordova

**Android 已修改为Gradle打包方式。build的时候可能会拉不下来，请百度‘jcenter 慢’解决**

**本次升级我只验证了click事件和getLaunchInfo功能，如果有其他功能不可用，请提交issue。**

## 关于开启厂商推送通道

***由于厂商通道，目前只支持android 3.2.6版本，经我测试。存在如下BUG，由于不便于插件化，所以我就不支持了。如果你有android开发能力可以更具下面的思路解决，如果没有就也可以等待官方支持4.2.0***

|平台|BUG|解决思路
|----|---|---|
|小米|当app在前台时，点击通知不会回调onNotifactionClickedResult 方法|在onNewIntent中接收小米的回调数据|
|华为|当app退出或者杀进程后，点击通知打开app，调用，getLaunchInfo发回为空|自己新建一个专门接收华为点击广播的接收器，在接收器中把传递来的数据存在跨进程（Mode=MODE_MULTI_PROCESS）的SharedPreferences，然后在getLaunchInfo中去取出来

>1.手动删除`工程目录/plugins/cordova-plugin-xgpush/sdk/android/build-extras.gradle`,里面的注释和添加相应配置。

>2.手动删除`工程目录/plugins/cordova-plugin-xgpush/src/android/XGPushPlugin.java`,里面35到50行的注释和添加相应配置。

>3.手动删除`工程目录/platforms/android/cordova-plugin-xgpush/*-build-extras.gradle`,里面的注释和添加相应配置。

>4.手动删除`工程目录/platforms/android/src/net/sunlu/xgpush/XGPushPlugin.java`,里面35到50行的注释和添加相应配置。

SDK     | version
------- | --------------------------------
android | 4.2.0
ios     | 3.3.1

## 安装方法

打开控制台，进入 Cordova 项目目录，输入：

```bash
cordova plugin add https://github.com/huangliop/cordova-plugin-xgpush-hl.git --variable ACCESS_ID="Your ANDROID ID" --variable ACCESS_KEY="Your ANDROID Key" --variable IOS_ACCESS_ID="Your ID" --variable IOS_ACCESS_KEY="Your Key" 
```
## iOS 特别处理

iOS版本需要在xCode里面手动开启，[Push Notifications]和[Background Modes]。方法如下
[http://xg.qq.com/docs/ios_access/ios_access_guide.html](http://xg.qq.com/docs/ios_access/ios_access_guide.html)

## 示例
```js
      document.addEventListener("deviceready", onDeviceReady, false);

      function onDeviceReady() {
            xgpush.registerPush('account',function(s){
                console.log(s)
            },function(e){
                console.log(e)
            })

            xgpush.on("register", function (data) {
                console.log("register:", data);
            });

            xgpush.on("click", function (data) {
                alert("click:" + JSON.stringify(data));
            });

            xgpush.getLaunchInfo(function (data) {
                alert("getLaunchInfo：" + JSON.stringify(data));
            }); 
      }
```
## API

### 方法

方法|方法名|参数说明|成功回调|失败回调
------------------------------------|------------------|---------------------------------------------------|--------|--------
registerPush(account,success,error) | 绑定账号注册     | account：绑定的账号，绑定后可以针对账号发送推送消息|{data:"设备的token"}|{data:"",code:"",message:""} //android Only
unRegisterPush(account,success,error)       | 反注册           |account：绑定的账号|{flag:0}|{flag:0}
setTag(tagName)       | 设置标签         | tagName：待设置的标签名称
deleteTag(tagName)    | 删除标签         | tagName：待设置的标签名称
addLocalNotification(type,title,content,success,error) | 添加本地通知| type:1通知，2消息 title:标题 content:内容
enableDebug(debugMode,success,error)| 开启调试模式     |  debugMode：默认为false。如果要开启debug日志，设为true
getToken(callback)                  |  获取设备Token   |回调|设备的token|
setAccessInfo(accessId,accessKey)   | 设置访问ID，KEY  |
getLaunchInfo(success)              | app启动自定义参数| |返回的数据与click事件返回的一样
stopNotification()|终止信鸽推送服务以后，将无法通过信鸽推送服务向设备推送消息。再次启动app（即初始化插件）就会重新接收推送|iOS noly|

调用例子
```js
      xgpush.registerPush("account",function(event){},function(event){});
```

### 事件 Event

事件 |  事件名  | 
------------|---------------------|
register    |  注册账号事件       | 
unRegister  | 反注册事件          |
message     | 接收到新消息时解法  |
click       | 通知被点击          |
show        | 通知成功显示        |
deleteTag   | 删除标签事件        |
setTag      | 设计标签事件        |

```js
        xgpush.on("click",function(data){
          console.log(data);
          /**
           * {
           *   activity:"com.changan.test.push.MainActivity", //android Only
           * content:"这是内容",
           * customContent:"{"vvva":"789"}",
           * msgId:101217419,
           * notifactionId:0,   //android Only
           * notificationActionType:1, // android Only
           * title:"测试推送",
           * subtitle:"副标题", //iOS Only
           * type:"show"
           * }
        **/
        });
```
