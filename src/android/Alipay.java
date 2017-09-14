package com.taiemao.alipay;

import android.text.TextUtils;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.alipay.sdk.app.PayTask;
import com.alipay.sdk.app.EnvUtils;

import java.util.Map;


/**
 * This class echoes a string called from JavaScript.
 */
public class Alipay extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        try {
            JSONObject arguments = args.getJSONObject(0);
            String orderInfo = arguments.getString("orderInfo");
            // SANDBOX
            EnvUtils.setEnv(EnvUtils.EnvEnum.SANDBOX);
            this.pay(orderInfo, callbackContext);
        } catch (JSONException e) {
            callbackContext.error(new JSONObject());
            e.printStackTrace();
            return false;
        }
        return true;
    }

    private void pay(final String orderInfo, final CallbackContext callbackContext) {

        Log.i("Alipay:orderInfo",orderInfo);

        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {
                // 构造PayTask 对象
                PayTask alipay = new PayTask(cordova.getActivity());
                // 调用支付接口，获取支付结果

                Map<String, String> result = alipay.payV2(orderInfo, true);

                Log.i("Alipay result:","====================================");
                for(String key: result.keySet()) {
                    Log.i("Alipay:key: ",key + " value: " + result.get(key));
                }

                Log.i("Alipay result:","====================================");

                PayResult payResult = new PayResult(result);
                /**
                 对于支付结果，请商户依赖服务端的异步通知结果。同步通知结果，仅作为支付结束的通知。
                 */
                String resultInfo = payResult.getResult();// 同步返回需要验证的信息
                String resultStatus = payResult.getResultStatus();

                if (TextUtils.equals(resultStatus, "9000")) {
                    callbackContext.success(payResult.toJson());
                } else {
                    // 判断resultStatus 为非“9000”则代表可能支付失败
                    // “8000”代表支付结果因为支付渠道原因或者系统原因还在等待支付结果确认，最终交易是否成功以服务端异步通知为准（小概率状态）
                    if (TextUtils.equals(resultStatus, "8000")) {
                        callbackContext.success(payResult.toJson());
                    } else {
                        callbackContext.error(payResult.toJson());
                    }
                }
            }
        });
    }
}
