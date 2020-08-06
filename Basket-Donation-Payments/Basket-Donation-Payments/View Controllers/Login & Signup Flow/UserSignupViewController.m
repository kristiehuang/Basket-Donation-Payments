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
#import "APIManager.h"
#import "Nonprofit.h"
#import <Parse/Parse.h>
#import "Utils.h"

@interface UserSignupViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISwitch *isNonprofitSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePicImage;

@property (nonatomic, strong) User *user;

@end

@implementation UserSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextField.text = self.username;
    self.passwordTextField.text = self.password;
    self.userProfilePicImage.image = [UIImage imageNamed:@"PlaceholderProfilePic"];
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
} 

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)getStartedButtonTapped:(id)sender {
    if (!([self.firstNameTextField hasText] && [self.lastNameTextField hasText] && [self.emailTextField hasText] && [self.usernameTextField hasText] && [self.passwordTextField hasText])) {
        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"One or more text field is empty." andMessage:@"Please fill out all required info." okCompletion:nil cancelCompletion:nil];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}";
    NSPredicate *emailPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if (![emailPred evaluateWithObject:self.emailTextField.text]) {
        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Invalid email format." andMessage:@"Please check the email address is valid." okCompletion:nil cancelCompletion:nil];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    UIActivityIndicatorView *loadingIndicator = [Utils createUIActivityIndicatorViewOnView:self.view];
    NSString *segueIdentifierToPerform = (self.isNonprofitSwitch.on ? @"nonprofitCreationSegue" : @"signUpSuccessSegue");
    if ([segueIdentifierToPerform isEqualToString:@"nonprofitCreationSegue"] || [segueIdentifierToPerform isEqualToString:@"signUpSuccessSegue"]) {

        [self createUserToSave];
        if ([segueIdentifierToPerform isEqualToString:@"nonprofitCreationSegue"]) {
            [loadingIndicator stopAnimating];
            [self performSegueWithIdentifier:segueIdentifierToPerform sender:nil];
        } else if ([segueIdentifierToPerform isEqualToString:@"signUpSuccessSegue"]) {
            self.user.nonprofit = nil;
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
            [APIManager newStripeCustomerIdWithName:fullName andEmail:self.user.email withBlock:^(NSError * err, NSString * stripeId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (err == nil) {
                        self.user.userStripeId = stripeId;
                        [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            [loadingIndicator stopAnimating];
                            if (!succeeded) {
                                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not create user." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                                [self presentViewController:alert animated:YES completion:nil];
                            } else {
                                [self performSegueWithIdentifier:segueIdentifierToPerform sender:nil];
                            }
                        }];
                    } else {
                        [loadingIndicator stopAnimating];
                        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error creating Stripe customer." andMessage:err.localizedDescription okCompletion:nil cancelCompletion:nil];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                });
            }];
        }

    }
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
    self.user.profilePicFile = [Utils getFileFromImage:self.userProfilePicImage.image];

    self.user.recentDonations = [NSMutableArray array];
    self.user.favoriteNonprofits = [NSMutableArray array];
    self.user.favoriteBaskets = [NSMutableArray array];
}

#pragma mark Image Picker

- (IBAction)addPictureButtonTapped:(id)sender {
    [Utils createImagePickerVCWithVC:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.userProfilePicImage.image = editedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Navigation Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"nonprofitCreationSegue"]) {
        NonprofitSignupViewController *nonprofitSignupVC = [segue destinationViewController];
        nonprofitSignupVC.user = self.user;
        nonprofitSignupVC.nonprofit = self.user.nonprofit;
    }
    
}

- (IBAction)cancelButtonTapped:(id)sender { //FIXME: unwind segue
    UIAlertController *cancelConfirm = [Utils createAlertControllerWithTitle:@"Are you sure?" andMessage:@"You'll lose your account creation details." okCompletion:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"unwindSegue" sender:nil];
    } cancelCompletion:nil];
    [self presentViewController:cancelConfirm animated:YES completion:nil];
}

- (IBAction)unwindToUserSignup:(UIStoryboardSegue *)unwindSegue {
    NonprofitSignupViewController *sourceViewController = unwindSegue.sourceViewController;
    self.user.nonprofit = sourceViewController.nonprofit;
}

- (IBAction)moreInfoButtonTapped:(id)sender {
    
}

@end
