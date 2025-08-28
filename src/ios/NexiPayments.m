// NexiPayments/src/ios/NexiPayments.m
#import "NexiPayments.h"
#import <NexiPay/NexiPay.h>

@implementation NexiPayments

- (void)startPayment:(CDVInvokedUrlCommand*)command {
    // Store the callback ID for later use in the delegate methods
    self.callbackId = command.callbackId;

    [self.commandDelegate runInBackground:^{
        NSString* orderId = [command.arguments objectAtIndex:0];
        NSString* paymentUrl = [command.arguments objectAtIndex:1];

        if (orderId && paymentUrl) {
            NPCheckoutConfig *config = [[NPCheckoutConfig alloc] initWithPaymentUrl:paymentUrl];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[NPCheckout shared] checkoutWithViewController:self.viewController config:config delegate:self];
            });

            // Send a "No Result" status to inform Cordova that the result will be sent later
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        } else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid arguments"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
            self.callbackId = nil; // Clean up stored ID
        }
    }];
}

#pragma mark - NPCheckoutDelegate methods

- (void)checkoutDidCompleteWithResult:(NPCheckoutResult *)result {
    CDVPluginResult* pluginResult;

    if (result.isSuccess) {
        NSDictionary *successData = @{
            @"status": @"success",
            @"transactionId": result.transactionId ?: [NSNull null],
            @"correlationId": result.correlationId ?: [NSNull null]
        };
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:successData];
    } else {
        NSDictionary *errorData = @{
            @"status": @"failure",
            @"message": result.error.localizedDescription ?: @"Payment failed",
            @"correlationId": result.correlationId ?: [NSNull null]
        };
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorData];
    }

    if (self.callbackId) {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        self.callbackId = nil; // Clear the callback ID
    }
}

@end
