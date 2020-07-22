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

@interface InitialLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation InitialLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)loginButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];

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
        
        if ((inputUsername.length == 0) || (inputPassword.length == 0)) {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Empty username or password." andMessage:@"Please input a username and password." okCompletion:nil cancelCompletion:nil];

            [self presentViewController:alert animated:YES completion:nil];
        }
        
        [PFUser logInWithUsernameInBackground:inputUsername password:inputPassword block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            if (error != nil) {
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Oops, couldn't log you in." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
                
            }
        }];
        
    }
}

@end
