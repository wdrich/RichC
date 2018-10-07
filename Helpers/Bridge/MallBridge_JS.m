//
//  MallBridge_JS.m
//  richcore
//
//  Created by Apple on 2018/5/28.
//  Copyright © 2018年 WangDong. All rights reserved.
//

#import "MallBridge_JS.h"

NSString * MallBridge_js() {
#define __wvjb_js_func__(x) #x
    
    // BEGIN preprocessorJSCode
    static NSString * preprocessorJSCode = @__wvjb_js_func__(
                                                             ;(function() {
        if (window.MallBridge) {
            return;
        }
        window.MallBridge = {
        login: login,
        pay: pay,
        _handleMessageFromObjC: _handleMessageFromObjC
        };
        
        function login(key, nonce, signature, force) {
            _callObjcWithMessage({handlerName: 'login', data: {key, nonce, signature, force}});
        }
        
        function pay(target, merchantKey, refNo, amount, comment, returnUrl, notifyUrl, signature) {
            _callObjcWithMessage({handlerName: 'pay', data: {target, merchantKey, refNo, amount, comment, returnUrl, notifyUrl, signature}});
        }
        
        function _callObjcWithMessage(message) {
            var messageString = JSON.stringify(message);
            window.webkit.messageHandlers.observe.postMessage(messageString);
        }
        
        function _handleMessageFromObjC(messageJson) {
            var message = JSON.parse(messageJson);
            if (message.handlerName === 'login') {
                var ev = document.createEvent('HTMLEvents');
                ev.initEvent('MallBridgeLoginReady', false, false);
                ev.detail = message.data;
                document.dispatchEvent(ev);
            } else if (message.handlerName === 'logout') {
                var ev = document.createEvent('HTMLEvents');
                ev.initEvent('MallBridgeLogout', false, false);
                document.dispatchEvent(ev);
            } else if (message.handlerName === 'pay') {
                var ev = document.createEvent('HTMLEvents');
                ev.initEvent('MallBridgePaySuccess', false, false);
                ev.payment = message.data;
                document.dispatchEvent(ev);
            }
        }
        
        var ev = document.createEvent('HTMLEvents');
        ev.initEvent('MallBridgeReady', false, false);
        document.dispatchEvent(ev);
    })();
                                                             ); // END preprocessorJSCode
    
#undef __wvjb_js_func__
    return preprocessorJSCode;
};
