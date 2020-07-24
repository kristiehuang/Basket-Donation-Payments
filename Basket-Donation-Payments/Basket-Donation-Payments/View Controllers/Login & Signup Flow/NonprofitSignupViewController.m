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
    self.finishedSavingBoth = NO;
    
    if (self.nonprofit) {
        self.nonprofitProfileImageView.image = [Utils getImageFromPFFile:self.nonprofit.profilePicFile];
        self.nonprofitNameTextField.text = self.nonprofit.nonprofitName;
        self.nonprofitDescriptionTextView.text = self.nonprofit.nonprofitDescription;
        self.nonprofitCategoryTextField.text = self.nonprofit.category;
        self.nonprofitWebsiteTextField.text = self.nonprofit.websiteUrlString;
    } else {
        self.nonprofit = [Nonprofit new];
        self.nonprofitDescriptionTextView.text = @"Describe your nonprofit in 100 words or less.";
        self.nonprofitDescriptionTextView.textColor = [UIColor lightGrayColor];
        //TODO: twitter-like word-limitations
        //TODO: figure out document uplaod
        // https://stackoverflow.com/questions/37296929/implement-document-picker-in-swift-ios
    }

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
    [self saveNonprofitAndUserToParse];
}

-(void)saveNonprofitAndUserToParse {
    [self saveNonprofitDataToNonprofitObject];
    
    NSOperationQueue *opQueue = [NSOperationQueue new];

    NSBlockOperation *signupUserOp = [NSBlockOperation new];
    signupUserOp.queuePriority = NSOperationQueuePriorityHigh;
    __weak NSBlockOperation *weakSignupUserOp = signupUserOp;
    [signupUserOp addExecutionBlock:^{
        [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!succeeded) {
                [opQueue cancelAllOperations];
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save user." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }];
    
    NSBlockOperation *saveNonprofitOp = [NSBlockOperation new];
    saveNonprofitOp.queuePriority = NSOperationQueuePriorityHigh;
    __weak NSBlockOperation *weakSaveNonprofitOp = saveNonprofitOp;
    [saveNonprofitOp addExecutionBlock:^{
        [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if ([weakSaveNonprofitOp isCancelled]) {
                [self.user deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (!succeeded) {
                        NSLog(@"error");
                    }
                }];
                return;
            } else if (!succeeded) {
                [opQueue cancelAllOperations];
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save nonprofit." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }];
    
    
    NSBlockOperation *loginSegueOp = [NSBlockOperation new];
    //FIXME: loginSegueOp is still running first??
    loginSegueOp.queuePriority = NSOperationQueuePriorityLow;
    __weak NSBlockOperation *weakLoginSegueOp = loginSegueOp;
    [loginSegueOp addExecutionBlock:^{
        if (weakLoginSegueOp.isCancelled) {
            return;
        } else {
            //FIXME: Must perform segue in main thread
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
    [opQueue addOperation:signupUserOp];
    if (self.nonprofit) {
        [opQueue addOperation:saveNonprofitOp];
    }
    [opQueue addOperation:loginSegueOp];
    


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
    } else {
        [self saveNonprofitDataToNonprofitObject];
    }
}

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
