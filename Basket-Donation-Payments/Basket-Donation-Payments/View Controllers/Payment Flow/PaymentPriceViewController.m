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

@end

@implementation PaymentPriceViewController

//FIXME: limit input to 2 decimal points

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recipientLabel.text = [NSString stringWithFormat:@"to %@", self.basket.name];
    //TODO: add ability to change currency
    self.priceInputTextField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)nextButtonTapped:(id)sender {
    if ([self.priceInputTextField hasText]) {
        NSNumberFormatter *numFormat = [NSNumberFormatter new];
        numFormat.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *inputVal = [numFormat numberFromString:self.priceInputTextField.text];
        self.totalAmount = @([inputVal floatValue] * 100);
        [APIManager createPaymentIntentWithBasket:self.basket totalAmount:self.totalAmount withBlock:^(NSError * error, NSDictionary * dataDict) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error creating payment intent." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"AddBillingMethodSegue" sender:dataDict[@"clientSecret"]];
                });
            }
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
        billingVC.paymentIntentClientSecret = sender;
    }
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.text.length == 5) { //FIXME: MUST STOP EDITING AFTER 2 DECIMAL POINTS
        return YES;
    }
    return NO;
}

@end
