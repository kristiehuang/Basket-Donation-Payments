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

+ (void)createPaymentIntentWithBasket:(Basket*)basket totalAmount:(NSNumber*)totalAmount withBlock:(void (^)(NSError *, NSDictionary *))completion {
    NSString *backendURL = [APIManager getAPISecretKeysDict][@"Backend_Server_Url"];
    
    // Create a PaymentIntent by calling your server's endpoint.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@create-payment-intent", backendURL]];
    
    NSMutableArray<NSDictionary*> *arrayOfNonprofits = [NSMutableArray array];
    for (Nonprofit *np in basket.nonprofits) {
        NSDictionary* merchantInfo = @{
            @"merchantId0": np.stripeAccountId ?: @"acct_1H729uCedSPk3wZj", // FIXME: @"acct_1H729uCedSPk3wZj" is test value, need to re-create all Parse data with new nonprofits with Stripe Id
            @"percentage": @(1 / basket.nonprofits.count)

            //FIXME: use user-inputted nonprofitPercentages
            //            @"percentage": basket.nonprofitPercentages[np]
        };
        [arrayOfNonprofits addObject:merchantInfo];
    }
    NSDictionary *json = @{
        @"currency": @"usd",
        @"totalAmount": totalAmount,
        @"basketItems": arrayOfNonprofits,
        @"customer": [User currentUser].userStripeId ?: @"cus_HjQnvQtIHPPGtt", //FIXME: @"cus_HjQnvQtIHPPGtt" is test value, need to re-create all Parse data with new users with Stripe Id
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


+ (void) newStripeCustomerIdWithName:(NSString*)fullName andEmail:(NSString*)email withBlock:(void (^)(NSError *, NSString *))completion {
    NSString *backendURL = [APIManager getAPISecretKeysDict][@"Backend_Server_Url"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@create-new-customer", backendURL]];
    NSDictionary *json = @{
        @"fullName": fullName,
        @"email": email
    };
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    NSMutableURLRequest *request = [[NSURLRequest requestWithURL:url] mutableCopy];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error != nil || httpResponse.statusCode != 200) {
            completion(error, nil);
        }
        else {
            NSDictionary *dataDict =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"Created new Stripe Customer");
            completion(nil, dataDict[@"id"]);
        }
    }];
    [task resume];


}

+ (void) newNonprofitConnectedAccountWithEmail:(NSString*)email withAuthorizationCode:(NSString*)code withBlock:(void (^)(NSError *, NSString *))completion {

    NSString *backendURL = [APIManager getAPISecretKeysDict][@"Backend_Server_Url"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@create-new-connected-account", backendURL]];
    NSDictionary *json = @{
        @"authorizationCode": code,
        @"email": email
    };
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    NSMutableURLRequest *request = [[NSURLRequest requestWithURL:url] mutableCopy];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error != nil || httpResponse.statusCode != 200) {
            completion(error, nil);
        }
        else {
            NSDictionary *dataDict =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"Created new Stripe connected account");
            completion(nil, dataDict[@"connectedAccountId"]);
        }
    }];
    [task resume];
}

@end
