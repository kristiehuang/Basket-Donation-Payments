//
//  LoginWebKitViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/29/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "LoginWebKitViewController.h"
#import <WebKit/WebKit.h>
#import "User.h"
#import "Utils.h"
#import <UIKit/UIKit.h>
#import "APIManager.h"

@interface LoginWebKitViewController () <WKUIDelegate, WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation LoginWebKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self loadStripeLogin];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *absoluteString = [navigationAction request].URL.absoluteString;
    BOOL finished = (absoluteString.length >= 107) ? [[absoluteString substringToIndex:107] isEqualToString:@"https://github.com/kristiehuang/Basket-Donation-Payments/blob/master/Landing-Page-StripeConnectedAccount.md"] : NO;
    if (finished) {
        decisionHandler(WKNavigationActionPolicyCancel);
        NSString *authorizationCode = [absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/kristiehuang/Basket-Donation-Payments/blob/master/Landing-Page-StripeConnectedAccount.md?code=" withString:@""];

        [APIManager newNonprofitConnectedAccountWithEmail:self.user.email withAuthorizationCode:authorizationCode withBlock:^(NSError * error, NSString * connectedAccountId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil) {
                    // If successful, save account Stripe ID, save to Parse, and login segue.
                    self.nonprofit.stripeAccountId = connectedAccountId;
                    [self saveNonprofitAndUserToParse];
                } else {
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save nonprofit to Stripe." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }];


    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

}

- (void)loadStripeLogin {


    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore
     fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
        for (WKWebsiteDataRecord *record  in records) {
            if ( [record.displayName containsString:@"stripe"]) {
                [[WKWebsiteDataStore defaultDataStore]
                 removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{
                    //Removed cookies
                }];
            }
        }
    }
     ];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    NSString *redirectUri = @"https://github.com/kristiehuang/Basket-Donation-Payments/blob/master/Landing-Page-StripeConnectedAccount.md";
    NSString *platformClientId = [APIManager getAPISecretKeysDict][@"Stripe_Platform_Client_Id"];

    NSURL *oauthUrl = [NSURL URLWithString: [NSString stringWithFormat:@"https://connect.stripe.com/express/oauth/authorize?redirect_uri=%@&client_id=%@&stripe_user[email]=%@&suggested_capabilities[]=transfers", redirectUri, platformClientId, self.user.email]];


    NSURLRequest *request = [NSURLRequest requestWithURL:oauthUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    [self.webView loadRequest:request];
}


-(void)saveNonprofitAndUserToParse {

    [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (succeeded) {
                [self.nonprofit saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (succeeded) {
                            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                        } else {
                            [self.user deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                if (!succeeded) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save nonprofit." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                                        [self presentViewController:alert animated:YES completion:nil];
                                    });
                                }
                            }];
                            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save nonprofit." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    });
                }];
            } else {
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save user." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

@end
