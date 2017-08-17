/********* Alipay.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <AlipaySDK/AlipaySDK.h>

@interface Alipay : CDVPlugin {
  // Member variables go here.
}

@property(nonatomic,strong)NSString *currentCallbackId;

- (void)alipay:(CDVInvokedUrlCommand*)command;
@end

@implementation Alipay

- (void)alipay:(CDVInvokedUrlCommand*)command
{
  self.currentCallbackId = command.callbackId;
  NSString *signedString = [[command argumentAtIndex:0] objectForKey:@"orderInfo"]; 
  NSString *appScheme = @"taiemao";

  NSLog(@"--------------------------------"); 
  NSLog(@"--------"); 
  NSLog(@"sign = %@",signedString); 
  NSLog(@"app = %@",appScheme); 

      NSLog(@"9999999999999999");
      [[AlipaySDK defaultService] payOrder:signedString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
  
      NSLog(@"=============================="); 
      NSLog(@"reslut = %@",resultDic); 
      if ([[resultDic objectForKey:@"resultStatus"]  isEqual: @"9000"]) {
        [self successWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
      } else {
        [self failWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
      }
      NSLog(@"reslut = %@",resultDic);
    }];

}

- (void)handleOpenURL:(NSNotification *)notification
{
  NSURL* url = [notification object];

  if ([url isKindOfClass:[NSURL class]])
  {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
    if ([[resultDic objectForKey:@"resultStatus"]  isEqual: @"9000"]) {
      [self successWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
    } else {
      [self failWithCallbackID:self.currentCallbackId messageAsDictionary:resultDic];
    }
    }];
  }
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
  CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
  [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message
{
  CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
  [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)successWithCallbackID:(NSString *)callbackID messageAsDictionary:(NSDictionary *)message
{
  CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
  [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID messageAsDictionary:(NSDictionary *)message
{
  CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:message];
  [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}
@end
