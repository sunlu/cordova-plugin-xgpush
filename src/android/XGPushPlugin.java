package net.sunlu.xgpush;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import com.tencent.android.tpush.XGIOperateCallback;
import com.tencent.android.tpush.XGPushClickedResult;
import com.tencent.android.tpush.XGPushConfig;
import com.tencent.android.tpush.XGPushConstants;
import com.tencent.android.tpush.XGPushManager;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.text.TextUtils;
import android.util.Log;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;

public class XGPushPlugin extends CordovaPlugin {

    private Context context;
    private XGPushReceiver receiver;
    private static final String TAG = "XGPushPlugin";

    private final static List<String> methodList = Arrays.asList(
            "registerPush",
            "unregisterPush",
            "setTag",
            "deleteTag",
            "addLocalNotification",
            "setPushNotificationBuilder",
            "enableDebug",
            "getToken",
            "setAccessId",
            "setAccessKey");

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        context = cordova.getActivity().getApplicationContext();

        receiver = new XGPushReceiver(cordova,webView);
        IntentFilter filter = new IntentFilter();
        filter.addAction(XGPushConstants.ACTION_PUSH_MESSAGE);
        filter.addAction(XGPushConstants.ACTION_FEEDBACK);
        context.registerReceiver(receiver, filter);
    }

    @Override
    public boolean execute(final String action, final JSONArray data, final CallbackContext callbackContext) throws JSONException {
        Log.d(TAG, "> plugin invoke : action=" + action);

        if (!methodList.contains(action)) {
            return false;
        }

        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                try {
                    Method method = this.getClass().getDeclaredMethod(action, JSONArray.class, CallbackContext.class);
                    method.invoke(this, data, callbackContext);
                } catch (Exception e) {
                    Log.e(TAG, e.toString());
                }
            }
        });
        return true;
    }

    /**
     * fix for singletop
     */
    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        this.cordova.getActivity().setIntent(intent);
    }

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);

        XGPushClickedResult click = XGPushManager.onActivityStarted(this.cordova.getActivity());
        Log.d(TAG, "onResumeXGPushClickedResult: multitasking = " + multitasking + ", Result = " + click);
        if (click != null) {
            receiver.onNotifactionClickedResult(context,click);
        }
    }

    @Override
    public void onPause(boolean multitasking) {
        super.onPause(multitasking);
        Log.d(TAG, "onActivityStoped : multitasking=" + multitasking);
        XGPushManager.onActivityStoped(this.cordova.getActivity());
    }

    /////////////////////////////////////

    protected void registerPush(JSONArray data, CallbackContext callback) throws JSONException {

        String account = (data != null && data.length() > 0) ? data.getString(0) : null;

        XGIOperateCallback reply = new XGPushCallback(callback);
        if (TextUtils.isEmpty(account)) {
            Log.d(TAG, "> register public");
            XGPushManager.registerPush(context, reply);
        } else {
            Log.d(TAG, "> register private:" + account);
            XGPushManager.registerPush(context, account, reply);
        }
    }


    private void unregisterPush(JSONArray data, CallbackContext callback) {
        XGPushManager.unregisterPush(context, new XGPushCallback(callback));
    }

    private void setTag(JSONArray data, CallbackContext callback) throws JSONException {

        XGPushManager.setTag(context, data.getString(0));
    }

    private void deleteTag(JSONArray data, CallbackContext callback) throws JSONException {
        XGPushManager.deleteTag(context, data.getString(0));
    }

    private void addLocalNotification(JSONArray data, CallbackContext callback) throws JSONException {
        //XGLocalMessage message = new XGLocalMessage();
        //message.set
    }

    private void setPushNotificationBuilder(JSONArray data, CallbackContext callback) throws JSONException {
        //XGLocalMessage message = new XGLocalMessage();
        //message.set
    }


    private void enableDebug(JSONArray data, CallbackContext callback) throws JSONException {
        boolean debugMode = data.getBoolean(0);
        XGPushConfig.enableDebug(context, debugMode);
    }

    private void getToken(JSONArray data, CallbackContext callback) {

        String token = XGPushConfig.getToken(context);
        callback.success(token);
    }

    private void setAccessId(JSONArray data, CallbackContext callback) throws JSONException {
        long id = data.getLong(0);
        XGPushConfig.setAccessId(context, id);
    }

    private void setAccessKey(JSONArray data, CallbackContext callback) throws JSONException {
        String key = data.getString(0);
        XGPushConfig.setAccessKey(context, key);
    }
}
