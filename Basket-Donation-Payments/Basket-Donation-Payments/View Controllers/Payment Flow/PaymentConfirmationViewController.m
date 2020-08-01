//
//  PaymentConfirmationViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/28/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "PaymentConfirmationViewController.h"

@interface PaymentConfirmationViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *confirmationCheckmarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmationCheckmarkWidthConstraint;

@end

@implementation PaymentConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideNavigationThings:YES];
    self.confirmationCheckmarkImageView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:2 animations:^{
        self.confirmationCheckmarkImageView.hidden = NO;
        CGRect frame = CGRectMake(self.confirmationCheckmarkImageView.frame.origin.x, self.confirmationCheckmarkImageView.frame.origin.y, self.confirmationCheckmarkImageView.frame.size.width * 1.2, self.confirmationCheckmarkImageView.frame.size.height * 1.2);
        self.confirmationCheckmarkImageView.frame = CGRectOffset(frame, 0, 318);
    }];
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
