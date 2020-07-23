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
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *nonprofitHeaderPic;
@property (weak, nonatomic) IBOutlet UIImageView *nonprofitProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitWebsiteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedImageView;
@property (weak, nonatomic) IBOutlet UILabel *totalValueDonatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitDescriptionLabel;

@end

@implementation NonprofitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    self.nonprofitHeaderPic.image = [Utils getImageFromPFFile:self.nonprofit.headerPicFile];
    self.nonprofitProfilePic.image = [Utils getImageFromPFFile:self.nonprofit.profilePicFile];
    self.favoriteButton.selected = [[[User currentUser] favoriteNonprofits] containsObject:self.nonprofit];
    self.totalValueDonatedLabel.text = [NSString stringWithFormat:@"$%0.2f", self.nonprofit.totalDonationsValue];
    self.nonprofitNameLabel.text = self.nonprofit.nonprofitName;
    self.nonprofitCategoryLabel.text = self.nonprofit.category;
    self.nonprofitWebsiteLabel.text = self.nonprofit.websiteUrlString;
    self.nonprofitDescriptionLabel.text = self.nonprofit.nonprofitDescription;
}

- (IBAction)favoriteButtonTapped:(id)sender {
}


@end
