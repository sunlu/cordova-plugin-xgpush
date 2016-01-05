package net.sunlu.xgpush;

import org.apache.cordova.CallbackContext;
import org.json.JSONException;
import org.json.JSONObject;

import com.tencent.android.tpush.XGIOperateCallback;

public class XGPushCallback implements XGIOperateCallback {

  private CallbackContext callback;

  XGPushCallback(CallbackContext callback) {
    this.callback = callback;
  }

  @Override
  public void onFail(Object data, int errCode, String msg) {
    JSONObject results = new JSONObject();
    try {
      results.put("data", data);
      results.put("code", errCode);
      results.put("message", msg);
    } catch (JSONException e) {
      e.printStackTrace();
    }
    this.callback.error(results);
  }

  @Override
  public void onSuccess(Object data, int flag) {
    JSONObject results = new JSONObject();
    try {
      results.put("data", data);
      results.put("flag", flag);
    } catch (JSONException e) {
      e.printStackTrace();
    }
    this.callback.success(results);
  }

}
