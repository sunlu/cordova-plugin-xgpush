package net.sunlu.xgpush;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.util.Log;

import com.tencent.android.tpush.XGPushBaseReceiver;
import com.tencent.android.tpush.XGPushClickedResult;
import com.tencent.android.tpush.XGPushManager;
import com.tencent.android.tpush.XGPushRegisterResult;
import com.tencent.android.tpush.XGPushShowedResult;
import com.tencent.android.tpush.XGPushTextMessage;

public class XGPushReceiver extends XGPushBaseReceiver {

    private CallbackContext callback;

    private static final String TAG = "XGPushReceiver";

    public XGPushReceiver(CallbackContext callback) {
        this.callback = callback;
    }

    public void onResume(Context context, CordovaInterface cordova){
        XGPushClickedResult click = XGPushManager.onActivityStarted(cordova.getActivity());
        Log.d(TAG, "onResume: ClickedResult = " + click);

        if (click != null) {
            onNotifactionClickedResult(context, click);
        }
    }

    @Override
    public void onTextMessage(Context context, XGPushTextMessage message) {
        JSONObject data = new JSONObject();
        try {
            data.put("type", "message");
            data.put("content", message.getContent());
            data.put("title", message.getTitle());
            data.put("customContent", message.getCustomContent());
        } catch (JSONException e) {
            Log.e(TAG, "onTextMessage", e);
        }
        sendMessage(data);
    }

    @Override
    public void onRegisterResult(Context context, int errorCode, XGPushRegisterResult message) {

        Log.d(TAG, "registerResult: code = " + errorCode + ", message = " + message);

        JSONObject data = new JSONObject();
        try {
            data.put("type", "register");
            data.put("accessId", message.getAccessId());
            data.put("account", message.getAccount());
            data.put("deviceId", message.getDeviceId());
            data.put("ticket", message.getTicket());
            data.put("ticketType", message.getTicketType());
            data.put("token", message.getToken());
        } catch (JSONException e) {
            Log.e(TAG, "onRegisterResult", e);
        }
        sendMessage(data);
    }

    @Override
    public void onUnregisterResult(Context context, int errorCode) {
        JSONObject data = new JSONObject();
        try {
            data.put("type", "unregister");
            data.put("errorCode", errorCode);
        } catch (JSONException e) {
            Log.e(TAG, "onUnregisterResult", e);
        }
        sendMessage(data);
    }

    @Override
    public void onDeleteTagResult(Context context, int errorCode, String tagName) {
        JSONObject data = new JSONObject();
        try {
            data.put("type", "deleteTag");
            data.put("errorCode", errorCode);
            data.put("tagName", tagName);
        } catch (JSONException e) {
            Log.e(TAG, "onDeleteTagResult", e);
        }
        sendMessage(data);
    }

    @Override
    public void onSetTagResult(Context context, int errorCode, String tagName) {
        JSONObject data = new JSONObject();
        try {
            data.put("type", "setTag");
            data.put("errorCode", errorCode);
            data.put("tagName", tagName);
        } catch (JSONException e) {
            Log.e(TAG, "onSetTagResult", e);
        }
        sendMessage(data);
    }

    @Override
    public void onNotifactionClickedResult(Context context, XGPushClickedResult message) {
        sendMessage(convertClickedResult(message));
    }

    @Override
    public void onNotifactionShowedResult(Context context, XGPushShowedResult message) {
        JSONObject data = new JSONObject();
        try {
            String tmp=message.getCustomContent();
            if(tmp!=null&&!tmp.equals("")){
                JSONObject customContent=new JSONObject(message.getCustomContent());
                data.put("customContent", customContent);
            }
            data.put("type", "show");
            data.put("activity", message.getActivity());
            data.put("content", message.getContent());
            data.put("title", message.getTitle());
            data.put("msgId", message.getMsgId());
            data.put("notifactionId", message.getNotifactionId());
            data.put("notificationActionType", message.getNotificationActionType());
        } catch (JSONException e) {
            Log.e(TAG, "onNotifactionShowedResult", e);
        }
        sendMessage(data);
    }

    private void sendMessage(final JSONObject data) {
        PluginResult results = new PluginResult(PluginResult.Status.OK, data);
        results.setKeepCallback(true);
        callback.sendPluginResult(results);
    }

    public static JSONObject convertClickedResult(XGPushClickedResult message){
        JSONObject data = new JSONObject();

        if(message == null)
            return data;

        try {
            String tmp=message.getCustomContent();
            if(tmp!=null&&!tmp.equals("")){
                JSONObject customContent=new JSONObject(message.getCustomContent());
                data.put("customContent", customContent);
            }
            data.put("type", "click");
            data.put("actionType", message.getActionType());
            data.put("content", message.getContent());
            data.put("title", message.getTitle());
            data.put("msgId", message.getMsgId());
            data.put("activityName", message.getActivityName());
            data.put("notificationActionType", message.getNotificationActionType());
        } catch (JSONException e) {
            Log.e(TAG, "convertClickedResult Error", e);
        }

        return data;
    }
}
