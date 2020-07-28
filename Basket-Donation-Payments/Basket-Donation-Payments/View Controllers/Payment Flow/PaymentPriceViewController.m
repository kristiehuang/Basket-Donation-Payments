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

@end

@implementation PaymentPriceViewController

//FIXME: limit input to 2 decimal points

- (void)viewDidLoad {
    [super viewDidLoad];
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
        billingVC.totalAmount = [numFormat numberFromString:self.priceInputTextField.text];
//FIXME: Total amount is NSNumber
    }
}


@end
