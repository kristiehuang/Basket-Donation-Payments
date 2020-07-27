//
//  APIManager.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "APIManager.h"
#import <Parse/Parse.h>

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


@end
