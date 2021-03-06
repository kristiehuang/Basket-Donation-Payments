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
            @"merchantId0": np.stripeAccountId,
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
        @"customer": [User currentUser].userStripeId
    };
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
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
            completion(nil, dataDict[@"id"]);
        }
    }];
    [task resume];
}

+ (void)getSourceChargeIdWithPaymentIntent:(NSString*)paymentIntentId withBlock:(void (^)(NSError *, NSString *))completion {
    NSString *backendURL = [APIManager getAPISecretKeysDict][@"Backend_Server_Url"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@get-paymentintent-charge", backendURL]];
    NSDictionary *json = @{
        @"payment_intent": paymentIntentId,
    };
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
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
            completion(nil, dataDict[@"chargeId"]);
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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
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
            completion(nil, dataDict[@"connectedAccountId"]);
        }
    }];
    [task resume];
}


+ (void)createTransfersWithAmount:(NSNumber*)amount toConnectedStripeAccounts:(NSMutableArray<NSString*>*)connectedStripeAccounts withSourceTxId:(NSString*)sourceTxId withBlock:(void (^)(NSError *, NSString *))completion {
    NSInteger numberOfNonprofits = connectedStripeAccounts.count;
    NSInteger amountPerNonprofit = [amount doubleValue] / numberOfNonprofits;
    for (NSString *connectedStripeId in connectedStripeAccounts) {
        [self createSingleTransferWithAmount:[NSNumber numberWithLong:amountPerNonprofit] toId:connectedStripeId withSourceTxId:sourceTxId withBlock:completion];
    }
}

+ (void)createSingleTransferWithAmount:(NSNumber*)amount toId:(NSString*)connectedId withSourceTxId:(NSString*)sourceTxId withBlock:(void (^)(NSError *, NSString *))completion {
    NSString *backendURL = [APIManager getAPISecretKeysDict][@"Backend_Server_Url"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@create-transfer", backendURL]];
    NSDictionary *json = @{
        @"amount": amount,
        @"currency": @"usd",
        @"destination": connectedId,
        @"source_transaction": sourceTxId
    };
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
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
            completion(nil, dataDict[@"transferId"]);
        }
    }];
    [task resume];
}

@end
