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
#import <UIKit/UIKit.h>

@interface NonprofitSignupViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
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
    self.nonprofitDescriptionTextView.delegate = self;
    self.finishedSavingBoth = false;
    self.nonprofit = [Nonprofit new];
    self.nonprofitDescriptionTextView.text = @"Describe your nonprofit in 100 words or less.";
    self.nonprofitDescriptionTextView.textColor = [UIColor lightGrayColor];
    //TODO: twitter-like word-limitations
    

    //TODO: figure out document uplaod
    // https://stackoverflow.com/questions/37296929/implement-document-picker-in-swift-ios
}

- (IBAction)addPictureButtonTapped:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    BOOL cameraSourceAvail = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibAvail = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if (cameraSourceAvail && photoLibAvail) {
        //UIActionSheet to pick a source type
        UIAlertController *sourceTypePicker = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        }];
        UIAlertAction *photoLib = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }];
        [sourceTypePicker addAction:camera];
        [sourceTypePicker addAction:photoLib];
        [self presentViewController:sourceTypePicker animated:YES completion:nil];
    } else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    self.nonprofitProfileImageView.image = editedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getStartedButtonTapped:(id)sender {
    [self saveNonprofitAndUserToParse];
}

-(void)saveNonprofitAndUserToParse {
    self.nonprofit.profilePicFile = [Utils getFileFromImage:self.nonprofitProfileImageView.image];
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.textColor isEqual:[UIColor lightGrayColor]]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.nonprofitDescriptionTextView.text = @"Describe your nonprofit in 100 words or less.";
        self.nonprofitDescriptionTextView.textColor = [UIColor lightGrayColor];
    }
}

@end
