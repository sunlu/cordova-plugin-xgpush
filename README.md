# 腾讯信鸽推送 for Cordova

***本次升级我只验证了部分功能，如果有其他功能不可用，请提交issue。***

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

方法                                | 方法名           | 参数说明 |成功回调|失败回调
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

调用例子
```js
      xgpush.registerPush("account",function(event){},function(event){});
```
### 事件 Event

事件        |  事件名             |                
------------|---------------------|------------------------------------------
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
           *   activity:"com.changan.test.push.MainActivity",
           * content:"这是内容",
           * customContent:"{"vvva":"789"}",
           * msgId:101217419,
           * notifactionId:0,
           * notificationActionType:1,title:"测试推送",
           * type:"show"
           * }
        **/
        });
```
