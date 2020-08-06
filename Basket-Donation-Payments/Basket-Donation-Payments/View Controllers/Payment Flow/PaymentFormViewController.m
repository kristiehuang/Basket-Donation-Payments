//
//  PaymentFormViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/27/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "PaymentFormViewController.h"
#import <Stripe/Stripe.h>
#import "User.h"
#import "BasketTransaction.h"
#import "Utils.h"
#import "APIManager.h"
#import "Nonprofit.h"
#import "FeaturedValueWeight.h"

@interface PaymentFormViewController ()
@property (weak) STPPaymentCardTextField *cardTextField;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIStackView *poweredByStripeStackView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation PaymentFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpPaymentView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
}


- (IBAction)payButtonTapped:(id)sender {
    [self pay];
}

- (void)pay {
    self.loadingIndicator = [Utils createUIActivityIndicatorViewOnView:self.view];
    [APIManager submitPaymentWithCard:self.cardTextField.cardParams clientSecret:self.paymentIntentClientSecret andBlock:^(NSError * error, STPPaymentHandlerActionStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case STPPaymentHandlerActionStatusFailed: {
                    [self.loadingIndicator stopAnimating];
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Payment failed." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case STPPaymentHandlerActionStatusCanceled: {
                    [self.loadingIndicator stopAnimating];
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Payment cancelled." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case STPPaymentHandlerActionStatusSucceeded: {
                    NSOperationQueue *queue = [NSOperationQueue new];
                    __weak typeof(self) weakSelf = self;
                    [queue addOperationWithBlock:^{
                        [weakSelf savePaymentTxToParse];
                    }];
                    [queue addOperationWithBlock:^{
                        [weakSelf createTransfers];
                    }];
                    [queue addOperationWithBlock:^{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [weakSelf.loadingIndicator stopAnimating];
                            [self performSegueWithIdentifier:@"PaymentConfirmedSegue" sender:nil];
                            self.tabBarController.hidesBottomBarWhenPushed = YES;
                        }];
                    }];
                    break;
                }
                default:
                    [self.loadingIndicator stopAnimating];
                    break;
            }
        });
    }];
}

- (void)savePaymentTxToParse {
    BasketTransaction *basketTx = [BasketTransaction new];
    basketTx.basketRecipient = self.basket;
    basketTx.madeByUser = [User currentUser];
    basketTx.totalAmount = self.totalAmount;
    [self.basket.allTransactions addObject:basketTx];
    [self updateBasketFeaturedValueWeights];

    [self.basket saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save payment to Parse server." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

- (void)createTransfers {
    NSOperationQueue *queue = [NSOperationQueue new];
    __weak typeof(self) weakSelf = self;

    [queue addOperationWithBlock:^{
        [APIManager getSourceChargeIdWithPaymentIntent:weakSelf.paymentIntentId withBlock:^(NSError * err, NSString * chargeId) {
            if (err) {
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not get chargeId to create transfer." andMessage:err.localizedDescription okCompletion:nil cancelCompletion:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf presentViewController:alert animated:YES completion:nil];
                });
                [queue cancelAllOperations];
            } else {
                NSMutableArray<NSString*> *connectedStripeAccounts = [NSMutableArray array];
                for (Nonprofit* n in weakSelf.basket.nonprofits) {
                    [connectedStripeAccounts addObject:n.stripeAccountId];
                }
                [APIManager createTransfersWithAmount:self.totalAmount toConnectedStripeAccounts:connectedStripeAccounts withSourceTxId:chargeId withBlock:^(NSError * err, NSString * transferId) {
                    if (err) {
                        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not create transfer." andMessage:err.localizedDescription okCompletion:nil cancelCompletion:nil];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf presentViewController:alert animated:YES completion:nil];
                        });
                        [queue cancelAllOperations];
                    }
                }];
                [weakSelf updateTotalDonationValues];
            }
        }];
    }];

}

- (void)updateTotalDonationValues {
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.loadingIndicator startAnimating];
        }];
    }];
    NSInteger numberOfNonprofits = self.basket.nonprofits.count;
    NSInteger amountPerNonprofit = [self.totalAmount intValue] / numberOfNonprofits;
    __weak typeof(self) weakSelf = self;
    [queue addOperationWithBlock:^{
        weakSelf.basket = [weakSelf.basket fetch];
        weakSelf.basket.totalDonatedValue =  [NSNumber numberWithLong:[weakSelf.basket.totalDonatedValue intValue] + [weakSelf.totalAmount intValue]];
        if (![self.basket save]) {
            [queue cancelAllOperations];
        }
    }];
    [queue addOperationWithBlock:^{
        for (Nonprofit *n in weakSelf.basket.nonprofits) {
            Nonprofit *nonprofit = [n fetch];
            nonprofit.totalDonationsValue =  [NSNumber numberWithLong:[nonprofit.totalDonationsValue intValue] + amountPerNonprofit];
            if (![nonprofit save]) {
                [queue cancelAllOperations];
            }
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.loadingIndicator stopAnimating];
        }];
    }];

}

- (void)updateBasketFeaturedValueWeights {
    FeaturedValueWeight *ftWeights = self.basket.featuredValueWeights;
    NSUInteger maxNumberOfDonationsWeight = 40;
    [ftWeights fetch];
    ftWeights.numberOfDonationsWeight = MIN(self.basket.allTransactions.count, maxNumberOfDonationsWeight);
    NSInteger sumFeaturedVal = ftWeights.numberOfDonationsWeight + ftWeights.predeterminedEventRelevancyWeight + ftWeights.userFavoritesWeight;

    self.basket.totalFeaturedValue = [[NSNumber alloc] initWithLong:sumFeaturedVal];;
}

# pragma mark STPAuthenticationContext
- (UIViewController *)authenticationPresentingViewController {
    return self;
}

- (void)setUpPaymentView {
    STPPaymentCardTextField *cardTextField = [[STPPaymentCardTextField alloc] init];
    self.cardTextField = cardTextField;
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[cardTextField, self.poweredByStripeStackView, self.payButton]];
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
