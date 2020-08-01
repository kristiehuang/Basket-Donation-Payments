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

@interface PaymentPriceViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *priceInputTextField;
@property (weak, nonatomic) IBOutlet UILabel *recipientLabel;

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
        [self performSegueWithIdentifier:@"AddBillingMethodSegue" sender:nil];
    } else {
        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"No value input." andMessage:@"How much would you like to donate?" okCompletion:nil cancelCompletion:nil];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddBillingMethodSegue"]) {
        PaymentFormViewController *billingVC = [segue destinationViewController];
        billingVC.basket = self.basket;
        NSNumberFormatter *numFormat = [NSNumberFormatter new];
        numFormat.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *inputVal = [numFormat numberFromString:self.priceInputTextField.text];
        billingVC.totalAmount = @([inputVal floatValue] * 100);
        //FIXME: Total amount is NSNumber
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.text.length == 5) { //FIXME: MUST STOP EDITING AFTER 2 DECIMAL POINTS
        return YES;
    }
    return NO;
}

@end
