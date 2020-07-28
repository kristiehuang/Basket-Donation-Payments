//
//  APIManager.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "APIManager.h"
#import "Utils.h"
#import "User.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Stripe/Stripe.h>
#import "BasketTransaction.h"
#import "Basket.h"
#import "Nonprofit.h"


@implementation APIManager

+(NSDictionary*)getAPISecretKeysDict {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"APIKeysSecret" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    return dict;
}

-(void)fetchBraintreeClientToken {
    //NSDictionary *apiKeys = [self getAPISecretKeysDict];
    NSURL *clientTokenURL = [NSURL URLWithString:@"https://braintree-sample-merchant.herokuapp.com/client_token"];
    NSMutableURLRequest *clientTokenRequest = [NSMutableURLRequest requestWithURL:clientTokenURL];
    [clientTokenRequest setValue:@"text/plain" forHTTPHeaderField:@"Accept"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:clientTokenRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // TODO: Handle errors
        //NSString *clientToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *clientToken = @"CLIENT_TOKEN_FROM_SERVER"; //TODO: demo client token
        
        // As an example, you may wish to present Drop-in at this point.
        // Continue to the next section to learn more...
    }] resume];
}


+ (void)createPaymentIntentWithBasket:(Basket*)basket totalAmount:(NSNumber*)totalAmount withBlock:(void (^)(NSError *, NSDictionary *))completion {
    NSString *backendURL = [APIManager getAPISecretKeysDict][@"Backend_Server_Url"];
    
    // Create a PaymentIntent by calling your server's endpoint.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@create-payment-intent", backendURL]];
    
    BasketTransaction *basketTx = [BasketTransaction new]; //
    basketTx.basketRecipient = basket;
    basketTx.madeByUser = [User currentUser];
    basketTx.totalAmount = totalAmount;
    //TODO: do I need to save basketTx to Parse if I can retrieve from Stripe API?
    
    NSMutableArray<NSDictionary*> *arrayOfNonprofits = [NSMutableArray array];
    for (Nonprofit *np in basket.nonprofits) {
        NSDictionary* merchantInfo = @{
            @"merchantId0": @"acct_1H729uCedSPk3wZj", //Test value for now.
            @"percentage": @(1 / basket.nonprofits.count) //FIXME: needs to be double, wrapped in NSNumber

            //FIXME: instantiate Nonprofit object with stripeId
            //FIXME: use user-inputted nonprofitPercentages
//            @"merchantId0": np.stripeId,
//            @"percentage": basket.nonprofitPercentages[np]
        };
        [arrayOfNonprofits addObject:merchantInfo];
    }
    NSDictionary *json = @{
        @"currency": @"usd",
        @"totalAmount": totalAmount,
        @"basketItems": arrayOfNonprofits,
        @"customer": @"cus_HjQnvQtIHPPGtt", //Test value for now.

        //FIXME: instantiate user with Stripe ID
        //@"customer": [User currentUser].userStripeId,
        @"transferGroup": @"tempTransferGroupId", //FIXME: unique transfer group
    };
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    NSMutableURLRequest *request = [[NSURLRequest requestWithURL:url] mutableCopy];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
        NSError *error = requestError;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error != nil || httpResponse.statusCode != 200) {
            completion(error, nil);
        }
        else {
            NSDictionary *dataDict =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"Created PaymentIntent");
            completion(nil, dataDict);
        }
    }];
    [task resume];
}

+ (void)submitPaymentWithCard:(STPPaymentMethodCardParams*)params clientSecret:(NSString*)clientSecret andBlock:(void (^)(NSError *, STPPaymentHandlerActionStatus))completion {
    
    // Create STPPaymentIntentParams with card details
    STPPaymentMethodCardParams *cardParams = params;
    STPPaymentMethodParams *paymentMethodParams = [STPPaymentMethodParams paramsWithCard:cardParams billingDetails:nil metadata:nil];
    STPPaymentIntentParams *paymentIntentParams = [[STPPaymentIntentParams alloc] initWithClientSecret:clientSecret];
    paymentIntentParams.paymentMethodParams = paymentMethodParams;
    
    // Submit the payment
    STPPaymentHandler *paymentHandler = [STPPaymentHandler sharedHandler];
    [paymentHandler confirmPayment:paymentIntentParams withAuthenticationContext:self completion:^(STPPaymentHandlerActionStatus status, STPPaymentIntent *paymentIntent, NSError *error) {
        completion(error, status);
    }];
}

@end
