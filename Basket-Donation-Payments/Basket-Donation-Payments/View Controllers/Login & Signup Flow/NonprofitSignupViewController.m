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
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;


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
        self.nonprofitDescriptionTextView.placeholder = @"Describe your nonprofit.";
        self.nonprofitDescriptionTextView.placeholderColor = [UIColor lightGrayColor];
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
        return;
    }
    self.loadingIndicator = [Utils createUIActivityIndicatorViewOnView:self.view];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
    [APIManager newStripeCustomerIdWithName:fullName andEmail:self.user.email withBlock:^(NSError * err, NSString * stripeId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (err == nil) {
                self.user.userStripeId = stripeId;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self saveNonprofitDataToNonprofitObject];
                    [self.loadingIndicator stopAnimating];

                    // Segues to open WKWebView to load oAuth link to create Stripe Connected Account for nonprofit, then redirects back in-app with RedirectURL. Will also create Parse Nonprofit.
                    [self performSegueWithIdentifier:@"CreateStripeAccountSegue" sender:nil];
                });
            } else {
                [self.loadingIndicator stopAnimating];
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Error creating Stripe customer." andMessage:err.localizedDescription okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

- (void)saveNonprofitDataToNonprofitObject {
    self.nonprofit.profilePicFile = [Utils getFileFromImage:self.nonprofitProfileImageView.image];
    self.nonprofit.nonprofitName = self.nonprofitNameTextField.text;
    self.nonprofit.nonprofitDescription = self.nonprofitDescriptionTextView.text;
    self.nonprofit.category = self.nonprofitCategoryTextField.text;
    self.nonprofit.websiteUrlString = self.nonprofitWebsiteTextField.text;
    self.user.nonprofit = self.nonprofit;
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
