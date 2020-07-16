//
//  BasketViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "BasketViewController.h"
#import "BraintreePayPal.h"
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"

@interface BasketViewController ()

@end

@implementation BasketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)donateButtonTapped:(id)sender {
    //test make paypal
    
    //BRAINTREE THINGS
//    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:@"sandbox_hc9nwmtg_8w2hqmbw5t62ppzm"]; //TODO: switch to production tokenization key before live. Are publishable can include in public app.
//    [self showDropIn:@"sandbox_hc9nwmtg_8w2hqmbw5t62ppzm"];
}

- (void)showDropIn:(NSString *)clientTokenizationKey {
    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:clientTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {

        if (error != nil) {
            NSLog(@"ERROR %@", error.localizedDescription);
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
        } else {
            // Use the BTDropInResult properties to update your UI
            NSLog(@"%@", result.paymentMethod);
            // result.paymentOptionType
            // result.paymentMethod
            // result.paymentIcon
            // result.paymentDescription
        }
    }];
    [self presentViewController:dropIn animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
