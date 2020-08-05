//
//  PaymentPriceViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/28/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "PaymentPriceViewController.h"
#import "PaymentFormViewController.h"
#import "Utils.h"
#import "APIManager.h"

@interface PaymentPriceViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *priceInputTextField;
@property (weak, nonatomic) IBOutlet UILabel *recipientLabel;
@property (nonatomic, strong) NSNumber *totalAmount;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation PaymentPriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recipientLabel.text = [NSString stringWithFormat:@"to %@", self.basket.name];
    self.priceInputTextField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)nextButtonTapped:(id)sender {
    if ([self.priceInputTextField hasText]) {
        self.loadingIndicator = [Utils createUIActivityIndicatorViewOnView:self.view];
        double inputVal = [self.priceInputTextField.text doubleValue];
        if ((inputVal < 1) || (inputVal >= 999999.99)) {
            [self.loadingIndicator stopAnimating];
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Value must be greater than $1 and less than $999,999.99." andMessage:@"Try again?" okCompletion:nil cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        self.totalAmount = [[NSNumber alloc] initWithDouble:inputVal*100];
        [APIManager createPaymentIntentWithBasket:self.basket totalAmount:self.totalAmount withBlock:^(NSError * error, NSDictionary * dataDict) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error creating payment intent." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    [self performSegueWithIdentifier:@"AddBillingMethodSegue" sender:dataDict];
                }
                [self.loadingIndicator stopAnimating];
            });
        }];
    } else {
        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"No value input." andMessage:@"How much would you like to donate?" okCompletion:nil cancelCompletion:nil];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddBillingMethodSegue"]) {
        PaymentFormViewController *billingVC = [segue destinationViewController];
        billingVC.basket = self.basket;
        billingVC.totalAmount = self.totalAmount;
        billingVC.paymentIntentClientSecret = sender[@"clientSecret"];
        billingVC.paymentIntentId = sender[@"paymentId"];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *expression = [[@"^[0-9]" stringByAppendingString:@"*((\\.|,)"] stringByAppendingString:@"[0-9]{0,2})?$"];

    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString options:0 range:NSMakeRange(0, [newString length])];
    return numberOfMatches != 0;
}

@end
