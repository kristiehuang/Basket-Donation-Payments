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
    self.totalAmount = @15000;

    [self setUpPaymentView];
    [self startCheckout];
    
    // Test values for now:
}

- (void)startCheckout {
    [APIManager createPaymentIntentWithBasket:self.basket totalAmount:self.totalAmount WithBlock:^(NSError * error, NSDictionary * dataDict) {
        if (error) {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error loading page." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            self.paymentIntentClientSecret = dataDict[@"clientSecret"];
        }
    }];
}

- (void)pay {
    if (!self.paymentIntentClientSecret) {
        NSLog(@"PaymentIntent hasn't been created");
        return;
    }
    
    [APIManager submitPaymentWithCard:self.cardTextField.cardParams clientSecret:self.paymentIntentClientSecret andBlock:^(NSError * error, STPPaymentHandlerActionStatus status) {
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

- (void)setUpPaymentView {
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
}

@end
