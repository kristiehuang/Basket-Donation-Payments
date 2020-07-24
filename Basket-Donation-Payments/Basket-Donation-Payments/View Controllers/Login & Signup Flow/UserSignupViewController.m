//
//  UserSignupViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "UserSignupViewController.h"
#import "NonprofitSignupViewController.h"
#import "User.h"
#import "Nonprofit.h"
#import <Parse/Parse.h>
#import "Utils.h"

@interface UserSignupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISwitch *isNonprofitSwitch;

@property (nonatomic, strong) User *user;

@end

@implementation UserSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextField.text = self.username;
    self.passwordTextField.text = self.password;
}

- (IBAction)getStartedButtonTapped:(id)sender {
    NSString *segueIdentifierToPerform = (self.isNonprofitSwitch.on ? @"nonprofitCreationSegue" : @"signUpSuccessSegue");
    if ([segueIdentifierToPerform isEqualToString:@"nonprofitCreationSegue"] || [segueIdentifierToPerform isEqualToString:@"signUpSuccessSegue"]) {
        
        if (!([self.firstNameTextField hasText] && [self.lastNameTextField hasText] && [self.emailTextField hasText] && [self.usernameTextField hasText] && [self.passwordTextField hasText])) {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"One or more text field is empty." andMessage:@"Please fill out all required info." okCompletion:nil cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [self createNewUser];
            if ([segueIdentifierToPerform isEqualToString:@"nonprofitCreationSegue"]) {
                [self performSegueWithIdentifier:segueIdentifierToPerform sender:nil];
                
            } else if ([segueIdentifierToPerform isEqualToString:@"signUpSuccessSegue"]) {
                self.user.nonprofit = nil;
                [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!succeeded) {
                        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not create user." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                        [self presentViewController:alert animated:YES completion:nil];
                    } else {
                        [self performSegueWithIdentifier:segueIdentifierToPerform sender:nil];
                        
                    }
                }];
            }
            [self createUserToSave];
            
            if ([segueIdentifierToPerform isEqualToString:@"nonprofitCreationSegue"]) {
                //TODO: verify everything looks good before moving on
                [self performSegueWithIdentifier:segueIdentifierToPerform sender:nil];
                
                
            } else if ([segueIdentifierToPerform isEqualToString:@"signUpSuccessSegue"]) {
                self.user.nonprofit = nil;
                [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!succeeded) {
                        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not create user." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                        [self presentViewController:alert animated:YES completion:nil];
                    } else {
                        [self performSegueWithIdentifier:segueIdentifierToPerform sender:nil];
                        
                    }
                }];
            }
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"nonprofitCreationSegue"]) {
        //send user deets to nonprofit creation segue but don't create yet
        //nonprofit property is still nil
        NonprofitSignupViewController *nonprofitSignupVC = [segue destinationViewController];
        nonprofitSignupVC.user = self.user;
        nonprofitSignupVC.nonprofit = self.user.nonprofit;
        
    }
    
}

- (void)createNewUser {
    self.user = [User user];
    self.user.firstName = (self.firstNameTextField.text.length == 0) ? @"" : self.firstNameTextField.text;
    self.user.lastName = (self.lastNameTextField.text.length == 0) ? @"" : self.lastNameTextField.text;
    self.user.username = self.usernameTextField.text;
    self.user.password = self.passwordTextField.text;
    self.user.email = self.emailTextField.text;
    
    NSData *profilePicData = UIImageJPEGRepresentation([UIImage imageNamed:@"PlaceholderProfilePic"], 1);
    self.user.profilePicFile = [PFFileObject fileObjectWithData:profilePicData]; //TODO: implement profile pic
    
    self.user.recentDonations = [NSMutableArray array];
    self.user.favoriteNonprofits = [NSMutableArray array];
}


- (void)createUserToSave {
    if (!self.user) {
        self.user = [User user];
    }
    self.user.firstName = (self.firstNameTextField.text.length == 0) ? @"" : self.firstNameTextField.text;
    self.user.lastName = (self.lastNameTextField.text.length == 0) ? @"" : self.lastNameTextField.text;
    self.user.username = self.usernameTextField.text;
    self.user.password = self.passwordTextField.text;
    self.user.email = self.emailTextField.text;
    
    NSData *profilePicData = UIImageJPEGRepresentation([UIImage imageNamed:@"PlaceholderProfilePic"], 1);
    self.user.profilePicFile = [PFFileObject fileObjectWithData:profilePicData]; //TODO: implement profile pic
    
    self.user.recentDonations = [NSMutableArray array];
    self.user.favoriteNonprofits = [NSMutableArray array];
}

- (IBAction)cancelButtonTapped:(id)sender {
    UIAlertController *cancelConfirm = [Utils createAlertControllerWithTitle:@"Are you sure?" andMessage:@"You'll lose your account creation details." okCompletion:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"unwindSegue" sender:nil];
        //TODO: make ACTUAL unwind segue otherwise memory leak
        
    } cancelCompletion:nil];
    [self presentViewController:cancelConfirm animated:YES completion:nil];
}

- (IBAction)unwindToUserSignup:(UIStoryboardSegue *)unwindSegue {
    NonprofitSignupViewController *sourceViewController = unwindSegue.sourceViewController;
    self.user.nonprofit = sourceViewController.nonprofit;
    // Use data from the view controller which initiated the unwind segue
}

- (IBAction)moreInfoButtonTapped:(id)sender {
    
}

@end
