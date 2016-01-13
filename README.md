# 腾讯信鸽推送 for Cordova

SDK     | version
------- | --------------------------------
android | Xg-Push-SDK-Android-2.42
ios     | Xg-Push-SDK-iOS-2.4.6.xcode6.4

## 安装方法

打开控制台，进入 Cordova 项目目录，输入：

```bash
cordova plugin add https://github.com/sunlu/cordova-plugin-xgpush --save \
--variable ACCESS_ID="Your ID"  --variable ACCESS_KEY="Your Key"
```
## 示例
      document.addEventListener("deviceready", onDeviceReady, false);

      function onDeviceReady() {
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

## API

### 方法

方法                                | 方法名           | 参数说明 
------------------------------------|------------------|---------------------------------------------------
registerPush(account,success,error) | 绑定账号注册     | account：绑定的账号，绑定后可以针对账号发送推送消息
unRegisterPush(success,error)       | 反注册           |
setTag(tagName,success,error)       | 设置标签         | tagName：待设置的标签名称
deleteTag(tagName,success,error)    | 删除标签         | tagName：待设置的标签名称
addLocalNotification(type,title,content,success,error) | 添加本地通知| type:1通知，2消息 title:标题 content:内容
enableDebug(debugMode,success,error)| 开启调试模式     |  debugMode：默认为false。如果要开启debug日志，设为true
getToken(callback)                  |  获取设备Token   |
setAccessInfo(accessId,accessKey)   | 设置访问ID，KEY  |
getLaunchInfo(success)              | app启动自定义参数|

调用例子
      xgpush.registerPush("account",function(event){},function(event){});

### 事件

事件        |  事件名             |  参数说明                  
------------|---------------------|------------------------------------------
register    |  注册账号事件       | 
unRegister  | 反注册事件          |
message     | 接收到新消息时解法  |
click       | 通知被点击          |
show        | 通知成功显示        |
deleteTag   | 删除标签事件        |
setTag      | 设计标签事件        |

        xgpush.on("click",function(data){
          console.log(data);
        });
