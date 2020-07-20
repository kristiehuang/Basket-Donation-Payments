//
//  NonprofitSignupViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "NonprofitSignupViewController.h"
#import <Parse/Parse.h>
#import "Nonprofit.h"
#import "Utils.h"

@interface NonprofitSignupViewController ()
@property (nonatomic, strong) Nonprofit *nonprofit;
@property (weak, nonatomic) IBOutlet UIImageView *nonprofitProfileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nonprofitNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *nonprofitDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *nonprofitCategoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *nonprofitWebsiteTextField;
//TODO: set up with Paypal, Braintree?
@property (nonatomic) BOOL finishedSavingBoth;

@end

@implementation NonprofitSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.finishedSavingBoth = false;
    self.nonprofit = [Nonprofit new]; //initWithDict
    //TODO: figure out document uplaod
    // https://stackoverflow.com/questions/37296929/implement-document-picker-in-swift-ios
}


- (IBAction)getStartedButtonTapped:(id)sender {
    [self saveNonprofitAndUserToParse];
}

-(void)saveNonprofitAndUserToParse {
    self.nonprofit.profilePicFile;
    self.nonprofit.nonprofitName = self.nonprofitNameTextField.text;
    self.nonprofit.nonprofitDescription = self.nonprofitDescriptionTextView.text;
    self.nonprofit.category = self.nonprofitCategoryTextField.text;
    self.nonprofit.websiteUrlString = [NSString stringWithFormat:@"%@", self.nonprofitWebsiteTextField.text];
    self.user.nonprofit = self.nonprofit;
    [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            if (self.finishedSavingBoth) {
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            } else {
                self.finishedSavingBoth = true;
            }

        } else {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save user." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    [self.nonprofit saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            if (self.finishedSavingBoth) {
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            } else {
                self.finishedSavingBoth = true;
            }
        } else {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save nonprofit." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
