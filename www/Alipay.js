var exec = require('cordova/exec');

exports.alipay = function(arg0, success, error) {
    exec(success, error, "Alipay", "alipay", [arg0]);
};
