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
#import "APIManager.h"
#import "Utils.h"
#import <UIKit/UIKit.h>
#import "LoginWebKitViewController.h"
@import UITextView_Placeholder;

@interface NonprofitSignupViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *nonprofitProfileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nonprofitNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *nonprofitDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *nonprofitCategoryTextField;
@property (weak, nonatomic) IBOutlet UITextField *nonprofitWebsiteTextField;
@property (nonatomic) BOOL finishedSavingBoth;



@end

@implementation NonprofitSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nonprofitNameTextField.delegate = self;
    self.nonprofitCategoryTextField.delegate = self;
    self.nonprofitWebsiteTextField.delegate = self;
    self.finishedSavingBoth = NO;
    
    if (self.nonprofit) {
        self.nonprofitProfileImageView.image = [Utils getImageFromPFFile:self.nonprofit.profilePicFile];
        self.nonprofitNameTextField.text = self.nonprofit.nonprofitName;
        self.nonprofitDescriptionTextView.text = self.nonprofit.nonprofitDescription;
        self.nonprofitDescriptionTextView.textColor = [UIColor blackColor];
        self.nonprofitCategoryTextField.text = self.nonprofit.category;
        self.nonprofitWebsiteTextField.text = self.nonprofit.websiteUrlString;
    } else {
        self.nonprofit = [Nonprofit new];
        self.nonprofitDescriptionTextView.placeholder = @"Describe your nonprofit in 100 words or less.";
        self.nonprofitDescriptionTextView.placeholderColor = [UIColor lightGrayColor];
        //TODO: twitter-like word-limitations
        //TODO: figure out document uplaod
        // https://stackoverflow.com/questions/37296929/implement-document-picker-in-swift-ios
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)addPictureButtonTapped:(id)sender {
    [Utils createImagePickerVCWithVC:self];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.nonprofitProfileImageView.image = editedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getStartedButtonTapped:(id)sender {
    if (!([self.nonprofitNameTextField hasText]
          && ![self.nonprofitDescriptionTextView.text isEqualToString:@""]
          && [self.nonprofitCategoryTextField hasText]
          && [self.nonprofitWebsiteTextField hasText])){
        UIAlertController *alert = [Utils createAlertControllerWithTitle:@"One or more text field is empty." andMessage:@"Please fill out all required info." okCompletion:nil cancelCompletion:nil];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
        //FIXME: user email must be valid otherwise server code will crash
        [APIManager newStripeCustomerIdWithName:fullName andEmail:self.user.email withBlock:^(NSError * err, NSString * stripeId) {
            if (err == nil) {
                self.user.userStripeId = stripeId;
                [self saveNonprofitDataToNonprofitObject];
                [self saveNonprofitToStripe];
            } else {
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error creating Stripe customer." andMessage:err.localizedDescription okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
}

/** Creates Stripe Connected Account for nonprofit. Runs after user is saved to Stripe. After completion, will save Nonprofit & User to Parse.
 Opens WKWebView to load oAuth link, then redirects back in-app with RedirectURL.
 */
- (void)saveNonprofitToStripe {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"CreateStripeAccountSegue" sender:nil];
    });


}


- (void)saveNonprofitDataToNonprofitObject {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.nonprofit.profilePicFile = [Utils getFileFromImage:self.nonprofitProfileImageView.image];
        self.nonprofit.nonprofitName = self.nonprofitNameTextField.text;
        self.nonprofit.nonprofitDescription = self.nonprofitDescriptionTextView.text;
        self.nonprofit.category = self.nonprofitCategoryTextField.text;
        self.nonprofit.websiteUrlString = self.nonprofitWebsiteTextField.text;
        self.user.nonprofit = self.nonprofit;
    });

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"unwindToUserSignup"]) {
    } else if ([segue.identifier isEqualToString:@"loginSegue"]) {
    } else if ([segue.identifier isEqualToString:@"CreateStripeAccountSegue"]) {
        LoginWebKitViewController *webVC = [segue destinationViewController];
        webVC.nonprofit = self.nonprofit;
        webVC.user = self.user;
    } else {
        [self saveNonprofitDataToNonprofitObject];
    }
}

@end
