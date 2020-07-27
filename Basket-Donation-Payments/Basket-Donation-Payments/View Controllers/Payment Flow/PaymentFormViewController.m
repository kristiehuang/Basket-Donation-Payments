//
//  PaymentFormViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/27/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "PaymentFormViewController.h"
#import <Stripe/Stripe.h>
#import "Utils.h"
#import "APIManager.h"

@interface PaymentFormViewController ()
@property (weak) STPPaymentCardTextField *cardTextField;
@property (weak) UIButton *payButton;
@property (strong) NSString *paymentIntentClientSecret;

@end

@implementation PaymentFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the Stripe card text field
    STPPaymentCardTextField *cardTextField = [[STPPaymentCardTextField alloc] init];
    self.cardTextField = cardTextField;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 5;
    button.backgroundColor = [UIColor systemBlueColor];
    button.titleLabel.font = [UIFont systemFontOfSize:22];
    [button setTitle:@"Pay" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    self.payButton = button;
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[cardTextField, button]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.spacing = 20;
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.leftAnchor constraintEqualToSystemSpacingAfterAnchor:self.view.leftAnchor multiplier:2],
        [self.view.rightAnchor constraintEqualToSystemSpacingAfterAnchor:stackView.rightAnchor multiplier:2],
        [stackView.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.view.safeAreaLayoutGuide.topAnchor multiplier:2],
    ]];
    
    [self createPaymentIntent];
    
}

- (void)createPaymentIntent {
    NSString *backendURL = [APIManager getAPISecretKeysDict][@"Backend_Server_Url"];
    // Create a PaymentIntent by calling your server's endpoint.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@create-payment-intent", backendURL]];
    NSDictionary *json = @{
        @"items": @[
                @{@"merchantId1": @"abc",
                  @"price": @8000
                },
                @{@"merchantId2": @"cde",
                  @"price": @8000
                },
                @{@"merchantId3": @"efg",
                  @"price": @1000 //in cents
                }
        ],
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
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error loading page." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            NSDictionary *dataDict =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"Created PaymentIntent %@", dataDict[@"description"]);
            
            self.paymentIntentClientSecret = dataDict[@"clientSecret"];
            NSString *publishableKey = dataDict[@"publishableKey"];
        }
    }];
    [task resume];
}

- (void)pay {
    if (!self.paymentIntentClientSecret) {
        NSLog(@"PaymentIntent hasn't been created");
        return;
    }
    // Create STPPaymentIntentParams with card details
    STPPaymentMethodCardParams *cardParams = self.cardTextField.cardParams;
    STPPaymentMethodParams *paymentMethodParams = [STPPaymentMethodParams paramsWithCard:cardParams billingDetails:nil metadata:nil];
    STPPaymentIntentParams *paymentIntentParams = [[STPPaymentIntentParams alloc] initWithClientSecret:self.paymentIntentClientSecret];
    paymentIntentParams.paymentMethodParams = paymentMethodParams;
    
    // Submit the payment
    STPPaymentHandler *paymentHandler = [STPPaymentHandler sharedHandler];
    [paymentHandler confirmPayment:paymentIntentParams withAuthenticationContext:self completion:^(STPPaymentHandlerActionStatus status, STPPaymentIntent *paymentIntent, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case STPPaymentHandlerActionStatusFailed: {
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Payment failed." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case STPPaymentHandlerActionStatusCanceled: {
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Payment cancelled." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case STPPaymentHandlerActionStatusSucceeded: {
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Payment succeeded." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                default:
                    break;
            }
        });
    }];
}

# pragma mark STPAuthenticationContext
- (UIViewController *)authenticationPresentingViewController {
    return self;
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
