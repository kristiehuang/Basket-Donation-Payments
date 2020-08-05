//
//  InitialLoginViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/13/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "InitialLoginViewController.h"
#import "UserSignupViewController.h"
#import <Parse/Parse.h>
#import "Utils.h"

@interface InitialLoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *basketLogoHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *basketLogoImage;

@end

@implementation InitialLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:.8 animations:^{
        self.basketLogoImage.frame = CGRectOffset(self.basketLogoImage.frame, 0, 20);
    } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 animations:^{
            self.basketLogoImage.frame = CGRectOffset(self.basketLogoImage.frame, 0, -30);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1 animations:^{
                    self.basketLogoImage.frame = CGRectOffset(self.basketLogoImage.frame, 0, 10);

                }];
            }];
    }];
}

- (IBAction)loginButtonTapped:(id)sender {
    NSString *inputUsername = self.usernameTextField.text;
    NSString *inputPassword = self.passwordTextField.text;
    if ((inputUsername.length == 0) || (inputPassword.length == 0)) {
        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Empty username or password." andMessage:@"Please input a username and password." okCompletion:nil cancelCompletion:nil];

        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIActivityIndicatorView *loadingIndicator = [Utils createUIActivityIndicatorViewOnView:self.view];
        [PFUser logInWithUsernameInBackground:inputUsername password:inputPassword block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingIndicator stopAnimating];
                if (error != nil) {
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Oops, couldn't log you in." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
                    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                }
            });
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([textField isEqual:self.passwordTextField]) {
        [self loginButtonTapped:nil];
    }
    return YES;
}


- (IBAction)signupButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"signupSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *inputUsername = self.usernameTextField.text;
    NSString *inputPassword = self.passwordTextField.text;
    
    if ([segue.identifier isEqualToString:@"signupSegue"]) {
        UINavigationController *navVC = [segue destinationViewController];
        UserSignupViewController *userSignupVC = navVC.viewControllers.firstObject;
        userSignupVC.username = inputUsername;
        userSignupVC.password = inputPassword;
        
    } else if ([segue.identifier isEqualToString:@"loginSegue"]) {

        
    }
}

@end
