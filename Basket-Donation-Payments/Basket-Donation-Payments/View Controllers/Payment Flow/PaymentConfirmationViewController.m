//
//  PaymentConfirmationViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/28/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "PaymentConfirmationViewController.h"

@interface PaymentConfirmationViewController ()

@end

@implementation PaymentConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideNavigationThings:YES];
}

- (IBAction)finishButtonTapped:(id)sender {
    [self hideNavigationThings:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.tabBarController.selectedIndex = 0;
}

- (void)hideNavigationThings:(BOOL)shouldHide {
    self.navigationController.navigationBarHidden = shouldHide;
    self.navigationItem.hidesBackButton = shouldHide;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = !shouldHide;
    }
}

@end
