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
    NSLog(@"%@", [navigationAction request].URL.absoluteString);
    NSString *absoluteString = [navigationAction request].URL.absoluteString;
    BOOL finished = [[absoluteString substringToIndex:107] isEqualToString:@"https://github.com/kristiehuang/Basket-Donation-Payments/blob/master/Landing-Page-StripeConnectedAccount.md"];
    if (finished) {
        decisionHandler(WKNavigationActionPolicyCancel);
        NSString *authorizationCode = [absoluteString stringByReplacingOccurrencesOfString:@"https://github.com/kristiehuang/Basket-Donation-Payments/blob/master/Landing-Page-StripeConnectedAccount.md?code=" withString:@""];

        [APIManager newNonprofitConnectedAccountWithEmail:self.user.email withAuthorizationCode:authorizationCode withBlock:^(NSError * error, NSString * connectedAccountId) {
            if (error == nil) {
                // If successful, save account Stripe ID, save to Parse, and login segue.
                self.nonprofit.stripeAccountId = connectedAccountId;
                [self saveNonprofitAndUserToParse];
            } else {
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save nonprofit to Stripe." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];


    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

}

- (void)loadStripeLogin {
    NSString *redirectUri = @"https://github.com/kristiehuang/Basket-Donation-Payments/blob/master/Landing-Page-StripeConnectedAccount.md";
    NSString *platformClientId = [APIManager getAPISecretKeysDict][@"Stripe_Platform_Client_Id"];

    NSURL *oauthUrl = [NSURL URLWithString: [NSString stringWithFormat:@"https://connect.stripe.com/express/oauth/authorize?redirect_uri=%@&client_id=%@&stripe_user[email]=%@&suggested_capabilities[]=transfers", redirectUri, platformClientId, self.user.email]];


    NSURLRequest *request = [NSURLRequest requestWithURL:oauthUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    [self.webView loadRequest:request];
}


-(void)saveNonprofitAndUserToParse {

    [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self.nonprofit saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                } else {
                    [self.user deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (!succeeded) {
                            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save nonprofit." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    }];
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save nonprofit." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        } else {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save user." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];

}

@end
