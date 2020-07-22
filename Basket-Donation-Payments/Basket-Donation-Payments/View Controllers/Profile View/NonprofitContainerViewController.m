//
//  NonprofitContainerViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/21/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "NonprofitContainerViewController.h"
#import "User.h"
#import "Nonprofit.h"

@interface NonprofitContainerViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *nonprofitImageView;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitWebsiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDonationValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *nonprofitDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nonprofitIsVerifiedCheckmark;
@property (nonatomic, strong) Nonprofit *nonprofit;
@property (weak, nonatomic) IBOutlet UITableView *foundInBasketsTableView;

@end

@implementation NonprofitContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[User currentUser] nonprofit] != nil) {
//        self.foundInBasketsTableView.delegate = self;
//        self.foundInBasketsTableView.dataSource = self;
        self.nonprofit = [[User currentUser] nonprofit];
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"objectId == %@", self.nonprofit.objectId];
        PFQuery *thisNonprofitQuery = [PFQuery queryWithClassName:@"Nonprofit" predicate:pred];
        self.nonprofit = [thisNonprofitQuery findObjects][0];
    //    if (self.nonprofit.verificationFiles == nil) { //FIXME: ISVERIFIED
    //        self.nonprofitIsVerifiedCheckmark.hidden = YES;
    //    }
        
        self.nonprofitNameLabel.text = self.nonprofit.nonprofitName;
        self.nonprofitCategoryLabel.text = self.nonprofit.category;
        self.totalDonationValueLabel.text = [NSString stringWithFormat:@"$%0.2f", self.nonprofit.totalDonationsValue];
        self.nonprofitWebsiteLabel.text = self.nonprofit.websiteUrlString;
        self.nonprofitDescriptionLabel.text = self.nonprofit.nonprofitDescription;
    }


}

- (IBAction)editButtonTapped:(id)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    //return Found in Baskets list
//}
//
//- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 3;
//}
@end
