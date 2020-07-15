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
#import <Parse/Parse.h>
#import "Utils.h"

@interface UserSignupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISwitch *isNonprofitSwitch;

@end

@implementation UserSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextField.text = self.username;
    self.passwordTextField.text = self.password;
}

- (IBAction)getStartedButtonTapped:(id)sender {
    NSString *segueIdentifierToPerform = (self.isNonprofitSwitch.on ? @"nonprofitCreationSegue" : @"signUpSuccessSegue");
    [self performSegueWithIdentifier:segueIdentifierToPerform sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Segue is not cancel segue
    if ([segue.identifier isEqualToString:@"nonprofitCreationSegue"] || [segue.identifier isEqualToString:@"signUpSuccessSegue"]) {
        User *newUser = [User user];
        newUser.firstName = self.firstNameTextField.text;
        newUser.lastName = self.lastNameTextField.text;
        newUser.username = self.usernameTextField.text;
        newUser.password = self.passwordTextField.text;
        newUser.email = self.emailTextField.text;
        
        NSData *profilePicData = UIImageJPEGRepresentation([UIImage imageNamed:@"PlaceholderProfilePic"], 1);
        newUser.profilePicFile = [PFFileObject fileObjectWithData:profilePicData]; //TODO: implement profile pic
        
        newUser.recentDonations = [NSMutableArray new]; //TODO: can i do this? dynamic NSArray xyz = NSMutableArray
        newUser.favoriteNonprofits = [NSMutableArray new]; //TODO: can i do this? dynamic NSArray xyz = NSMutableArray

        if ([segue.identifier isEqualToString:@"nonprofitCreationSegue"]) {
            //send user deets to nonprofit creation segue but don't create yet
            //nonprofit property is still nil
            NonprofitSignupViewController *nonprofitSignupVC = [segue destinationViewController];
            nonprofitSignupVC.user = newUser;
            
            
        } else if ([segue.identifier isEqualToString:@"signUpSuccessSegue"]) {
            //create user
            newUser.nonprofit = nil;

            //FIXME: add subclass to database
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        }
    }

    

}

- (IBAction)cancelButtonTapped:(id)sender {
    UIAlertController *cancelConfirm = [Utils createAlertControllerWithTitle:@"Are you sure?" andMessage:@"You'll lose your account creation details." okCompletion:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"unwindSegue" sender:nil];
        //TODO: make ACTUAL unwind segue otherwise memory leak

    } cancelCompletion:nil];
    [self presentViewController:cancelConfirm animated:YES completion:nil];
}

- (IBAction)moreInfoButtonTapped:(id)sender {
}

@end
