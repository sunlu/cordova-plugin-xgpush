package net.sunlu.xgpush;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;

import com.tencent.android.tpush.XGPushBaseReceiver;
import com.tencent.android.tpush.XGPushClickedResult;
import com.tencent.android.tpush.XGPushRegisterResult;
import com.tencent.android.tpush.XGPushShowedResult;
import com.tencent.android.tpush.XGPushTextMessage;

public class XGPushReceiver extends XGPushBaseReceiver {

  private CordovaInterface cordova;
  private CordovaWebView webView;

  public XGPushReceiver(CordovaInterface cordova,CordovaWebView webView) {
    this.cordova = cordova;
    this.webView = webView;
  }

  @Override
  public void onTextMessage(Context context, XGPushTextMessage message) {
    JSONObject data = new JSONObject();
    try {
      data.put("content", message.getContent());
      data.put("title", message.getTitle());
      data.put("customContent", message.getCustomContent());
    } catch (JSONException e) {
      e.printStackTrace();
    }
    sendMessage("onNotifactionClickedResult",data);
  }

  @Override
  public void onRegisterResult(Context context, int errorCode, XGPushRegisterResult message) {
    JSONObject data = new JSONObject();
    try {
      data.put("accessId", message.getAccessId());
      data.put("account", message.getAccount());
      data.put("deviceId", message.getDeviceId());
      data.put("ticket", message.getTicket());
      data.put("ticketType", message.getTicketType());
      data.put("token", message.getToken());
    } catch (JSONException e) {
      e.printStackTrace();
    }
    sendMessage("onRegisterResult",data);
  }

  @Override
  public void onUnregisterResult(Context context, int errorCode) {
    JSONObject data = new JSONObject();
    try {
      data.put("errorCode", errorCode);
    } catch (JSONException e) {
      e.printStackTrace();
    }
    sendMessage("onRegisterResult",data);
  }

  @Override
  public void onDeleteTagResult(Context context, int errorCode, String tagName) {
    JSONObject data = new JSONObject();
    try {
      data.put("errorCode", errorCode);
      data.put("tagName",tagName);
    } catch (JSONException e) {
      e.printStackTrace();
    }
    sendMessage("onDeleteTagResult",data);
  }

  @Override
  public void onSetTagResult(Context context, int errorCode, String tagName) {
    JSONObject data = new JSONObject();
    try {
      data.put("errorCode", errorCode);
      data.put("tagName",tagName);
    } catch (JSONException e) {
      e.printStackTrace();
    }
    sendMessage("onSetTagResult",data);
  }

  @Override
  public void onNotifactionClickedResult(Context context, XGPushClickedResult message) {
    JSONObject data = new JSONObject();
    try {
      data.put("actionType",message.getActionType());
      data.put("content", message.getContent());
      data.put("title", message.getTitle());
      data.put("customContent", message.getCustomContent());
      data.put("msgId",message.getMsgId());
      data.put("activityName",message.getActivityName());
      data.put("notificationActionType",message.getNotificationActionType());
    } catch (JSONException e) {
      e.printStackTrace();
    }
    sendMessage("onNotifactionClickedResult",data);
  }

  @Override
  public void onNotifactionShowedResult(Context context, XGPushShowedResult message) {
    JSONObject data = new JSONObject();
    try {
      data.put("activity",message.getActivity());
      data.put("content", message.getContent());
      data.put("title", message.getTitle());
      data.put("customContent", message.getCustomContent());
      data.put("msgId",message.getMsgId());
      data.put("notifactionId",message.getNotifactionId());
      data.put("notificationActionType",message.getNotificationActionType());
    } catch (JSONException e) {
      e.printStackTrace();
    }
    sendMessage("onNotifactionShowedResult",data);
  }

  private void sendMessage(final String callbackId,final JSONObject data){

    cordova.getThreadPool().execute(new Runnable() {
      public void run() {
        PluginResult results = new PluginResult(PluginResult.Status.OK, data);
        //results.setKeepCallback(true);
        webView.sendPluginResult(results,callbackId);
      }
    });
  }
}
