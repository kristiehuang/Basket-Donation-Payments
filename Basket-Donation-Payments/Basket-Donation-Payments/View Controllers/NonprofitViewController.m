//
//  NonprofitViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "NonprofitViewController.h"
#import "Nonprofit.h"
#import "Utils.h"
#import "User.h"


@interface NonprofitViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *nonprofitHeaderPic;
@property (weak, nonatomic) IBOutlet UIImageView *nonprofitProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitWebsiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalValueDonatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitDescriptionLabel;

@end

@implementation NonprofitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    if (self.basket) {
        self.nonprofitHeaderPic.image = [Utils getImageFromPFFile:self.basket.headerPicFile];
    } else {
        self.nonprofitHeaderPic.image = [UIImage imageNamed:@"PlaceholderHeaderPic"];
    }
    self.nonprofitProfilePic.image = [Utils getImageFromPFFile:self.nonprofit.profilePicFile];
    self.totalValueDonatedLabel.text = [NSString stringWithFormat: @"$%0.2f", [self.nonprofit.totalDonationsValue doubleValue] / 100];
    UIActivityIndicatorView *loadingIndicator = [Utils createUIActivityIndicatorViewOnView:self.view];
    [self.nonprofit fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingIndicator stopAnimating];
            self.totalValueDonatedLabel.text = [NSString stringWithFormat: @"$%0.2f", [self.nonprofit.totalDonationsValue doubleValue] / 100];
        });
    }];
    self.nonprofitNameLabel.text = self.nonprofit.nonprofitName;
    self.nonprofitCategoryLabel.text = self.nonprofit.category;
    self.nonprofitWebsiteLabel.text = self.nonprofit.websiteUrlString;
    self.nonprofitDescriptionLabel.text = self.nonprofit.nonprofitDescription;
}

- (IBAction)favoriteButtonTapped:(id)sender {
}


@end
