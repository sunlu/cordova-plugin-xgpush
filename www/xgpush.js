cordova.define("cordova-plugin-xgpush.xgpush", function(require, exports, module) {
//https://github.com/apache/cordova-plugin-network-information/blob/master/www/network.js
// https://github.com/katzer/cordova-plugin-local-notifications.git

var exec = require('cordova/exec'),
  cordova = require('cordova'),
  channel = require('cordova/channel'),
  utils = require('cordova/utils');

function XGPush() {
    this.available = false;
    this.token = false;

  this.channels = {
    'click': channel.create('click'),
    'message' : channel.create('message')
  };

  this.on = function(name,func){
    if (name in this.channels) {
      this.channels[name].subscribe(func);
    }
  };

  this.un = function(name,func){
    if (name in this.channels) {
      this.channels[name].unsubscribe(func);
    }
  };

  this.handler = function(event){
      if (event && (event.type in this.channels)) {
        this.channels[event.type].fire(event);
      }
  };

  this.registerPush = function(account,successCallback, errorCallback) {
         exec(successCallback, errorCallback, "XGPush", "registerPush", [account]);
       };
	   
  this.onEvent = function(event) {
        console.log(handler);
		handler(event);
       };

   var me = this;

      channel.onCordovaReady.subscribe(function() {
          me.registerPush(function(info) {
              console.log(info);
              me.available = true;
              //channel.onCordovaInfoReady.fire();
          },function(e) {
              me.available = false;
              utils.alert("[ERROR] Error initializing Cordova: " + e);
          });
		  
		  ecec(me.onEvent,null,"XGPush","onEvent",[]);
      });
}


module.exports = new XGPush();

});
