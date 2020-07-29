//
//  PaymentPriceViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/28/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "PaymentPriceViewController.h"
#import "PaymentFormViewController.h"

@interface PaymentPriceViewController ()
@property (weak, nonatomic) IBOutlet UITextField *priceInputTextField;
@property (weak, nonatomic) IBOutlet UILabel *recipientLabel;

@end

@implementation PaymentPriceViewController

//FIXME: limit input to 2 decimal points

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recipientLabel.text = [NSString stringWithFormat:@"to %@", self.basket.name];
    //TODO: add ability to change currency
}
- (IBAction)nextButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"AddBillingMethodSegue" sender:nil];
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


@end
