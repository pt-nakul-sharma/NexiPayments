// NexiPayments/src/ios/NexiPayments.h
#import <Cordova/CDVPlugin.h>
#import <NexiPay/NexiPay.h>

@interface NexiPayments : CDVPlugin <NPCheckoutDelegate>

// Property to store the callback ID for asynchronous calls
@property (nonatomic, strong) NSString* callbackId;

// The method that will be called from JavaScript
- (void)startPayment:(CDVInvokedUrlCommand*)command;

@end
