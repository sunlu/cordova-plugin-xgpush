var exec = require('cordova/exec'),
  cordova = require('cordova'),
  channel = require('cordova/channel'),
  utils = require('cordova/utils');

function XGPush() {

  var me = this;

  this.channels = {
    'click': channel.create('click'),
    'message': channel.create('message'),
    'register': channel.create('register'),
    'unRegister': channel.create('unRegister'),
    'show': channel.create('show'),
    'deleteTag': channel.create('deleteTag'),
    'setTag': channel.create('setTag'),
  };

  this.on = function (name, func) {
    if (name in me.channels) {
      me.channels[name].subscribe(func);
    }
  };

  this.un = function (name, func) {
    if (name in this.channels) {
      me.channels[name].unsubscribe(func);
    }
  };

  this.onEvent = function (event) {
    console.log(event);
    if (event && (event.eventType in me.channels)) {
      me.channels[event.eventType].fire(event);
    }
  };

  this.registerPush = function (account, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "XGPush", "registerPush", [account]);
  };

  this.unRegisterPush = function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, "XGPush", "unRegisterPush", []);
  };

  this.setTag = function (tagName, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "XGPush", "setTag", [tagName]);
  };

  this.deleteTag = function (tagName, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "XGPush", "deleteTag", [tagName]);
  };

  this.addLocalNotification = function (type, title, content, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "XGPush", "addLocalNotification", [type, title, content]);
  };

  this.enableDebug = function (debugMode, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "XGPush", "enableDebug", [debugMode]);
  };

  this.getToken = function (successCallback) {
    exec(successCallback, null, "XGPush", "getToken", []);
  };

  this.setAccessInfo = function (accessId, accessKey, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "XGPush", "setAccessInfo", [accessId, accessKey]);
  };

  channel.onCordovaReady.subscribe(function () {
    exec(me.onEvent, null, "XGPush", "addListener", []);

    me.registerPush(null, function (info) {
      console.log(info);
    }, function (e) {
      console.log(e);
      utils.alert("[ERROR] RegisterPush: " + e);
    });
  });

}

module.exports = new XGPush();
